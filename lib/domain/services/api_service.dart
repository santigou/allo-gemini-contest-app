import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiService{
  //TODO: Pasar llamado a la api para este servicio
  final TextEditingController _controller = TextEditingController();
  //Call gemini api
  Future<String> GeminiApiCall(String prompt) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=');

    try {

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['candidates'][0]['content']['parts'][0]['text'];
        print(text);
        return text;
      } else {
        return 'Failed to fetch API. Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}