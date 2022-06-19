import 'package:flutter/material.dart';
import 'package:ml_kit_demo/smart_reply_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google ML Kit Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SmartReplyDemo(),
    );
  }
}
