import 'package:flutter/material.dart';
import 'domain/services/api_service.dart';
import 'ui/pages/home/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();
  MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(apiService: apiService),
      debugShowCheckedModeBanner: false,
    );
  }
}