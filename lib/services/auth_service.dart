import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _sessionUser;
  String? _sessionMd5Pass;

  Dio? _dio;

  String? get currentUser => _sessionUser;
  bool get isLoggedIn => _sessionUser != null;

  Future<void> init() async {
    if (_dio != null) return;

    final ua = await _getRealUserAgent();

    _dio = Dio(BaseOptions(
      baseUrl: 'https://khwopa.edu.np/api/auth_v2',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent': ua,
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      },
      validateStatus: (status) => status! < 500,
    ));

    final prefs = await SharedPreferences.getInstance();
    _sessionUser = prefs.getString('username');
  }

  Future<String> _getRealUserAgent() async {
    if (kIsWeb) return 'Mozilla/5.0 (Web) Gecko/20100101 Firefox/139.0';

    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${packageInfo.appName}/${packageInfo.version} (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${packageInfo.appName}/${packageInfo.version} (iPhone; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('.', '_')} like Mac OS X)';
      }
    } catch (e) {
      debugPrint('UA Gen Failed: $e');
    }

    return 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36';
  }

  String _generateMd5(String input) =>
      crypto.md5.convert(utf8.encode(input)).toString();

  Future<Map<String, dynamic>> login(
      String username, String rawPassword) async {
    if (_dio == null) await init();

    final md5Password = _generateMd5(rawPassword);

    try {
      final response = await _dio!.get(
        '',
        queryParameters: {'user': username, 'pass': md5Password},
        options: Options(responseType: ResponseType.plain),
      );

      final body = response.data.toString().trim();

      if (response.statusCode == 403 ||
          response.statusCode == 503 ||
          body.contains('<!DOCTYPE html>')) {
        return {
          'success': false,
          'message':
              'Security check blocked connection (Cloudflare). Try again on 4G.'
        };
      }

      if (response.statusCode == 200) {
        if (body == 'Username or password incorrect.') {
          return {'success': false, 'message': body};
        }

        _sessionUser = username;
        _sessionMd5Pass = md5Password;

        // Parse CSV response: Name,ID,SomeNum,geoEmail,geoPassword
        try {
          final parts = body.split(',');
          if (parts.length >= 5) {
            final geoEmail = parts[3].trim();
            final geoPassword = parts[4].trim();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('geo_track_email', geoEmail);
            await prefs.setString('geo_track_password', geoPassword);
          }
        } catch (_) {
          // Silently ignore parsing errors for geo credentials
        }

        return {
          'success': true,
          'message': body.isNotEmpty ? body : 'Login successful'
        };
      }

      return {
        'success': false,
        'message': 'Server error: ${response.statusCode} - $body'
      };
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return {'success': false, 'message': 'Connection timed out.'};
      }
      return {'success': false, 'message': 'Network Error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  Future<void> logout() async {
    _sessionUser = null;
    _sessionMd5Pass = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
  }
}
