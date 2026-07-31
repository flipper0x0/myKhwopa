/* import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  String _info = '';

  Future<void> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _info = '''
Khwopa Student App v1.0.1
Developed by KCE079BCT037(@flipper0x0).

This app helps you track attendance, payments, resources, and more.
Pull down to see fresh content.
      ''';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Text(
        _info,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
} */
