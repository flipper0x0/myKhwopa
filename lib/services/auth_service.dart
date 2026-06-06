import 'dart:convert'; // For utf8.encode
import 'package:crypto/crypto.dart' // For md5
    as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://khwopa.edu.np/api/auth_v2',
    connectTimeout: const Duration(seconds: 5), 
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:139.0) '
          'Gecko/20100101 Firefox/139.0',
      'Accept': 'text/html,application/xhtml+xml,'
          'application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
    },
  ));

  String _generateMd5(String input) =>
      crypto.md5.convert(utf8.encode(input)).toString();

  Future<Map<String, dynamic>> login(
      String username, String rawPassword) async {
    final md5Password = _generateMd5(rawPassword);
    debugPrint('Login attempt for: $username'); 
    debugPrint('MD5 password: $md5Password'); 

    try {
      final response = await _dio.get(
        '',
        queryParameters: {'user': username, 'pass': md5Password},
        options: Options(responseType: ResponseType.plain),
      );

      debugPrint(
          'Status: ${response.statusCode}, Body: ${response.data}'); // avoid print[1]

      final body = response.data.toString().trim();
      if (response.statusCode == 200) {
        if (body == 'Username or password incorrect.') {
          return {'success': false, 'message': body};
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
      final status = e.response?.statusCode;
      final msg = e.response?.data?.toString().trim() ?? e.message;
      return {'success': false, 'message': 'Error $status: $msg'};
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}
