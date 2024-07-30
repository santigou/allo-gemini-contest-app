import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import 'message_service.dart';

class ApiService {
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: 'AIzaSyDDaieCLfRwr9KUyHvC7XTF98Noka1GsLY');

  //Call gemini api
  Future<String> geminiApiCall(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDDaieCLfRwr9KUyHvC7XTF98Noka1GsLY');
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
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        return 'Failed to fetch API. Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  String getTopicPrompt(String language,
      {String? userPrompt, String? level, String? existingTopics}) {
    print(level);
    return '''
    The user want to learn $language with 
    ${userPrompt == null ? "(generate a random topic avoid [$existingTopics] topics)" : "the following topic: \"$userPrompt\""} with the a $level level.
    Give the necessary steps as subtopics to complete the objective your
    response must return a json with as the following example, ONLY RETURN THE JSON, DON'T ADD ANY OTHER THING (for example not return json{...} or like that):
    {
      "name":(Give a brief name to the topic maximum 5 words),
      "description": (Give a description about the topic),
      "objectives": (Give a list of objectives to fulfill this topic divided by -),
      "summary": (Give a brief explanation about the topic and what the user is going to learn),
      "level": (Give the respective integer for the selectedLevel ($level) 1 for Basic, 2 for Intermediate, 3 for Advanced)
      "subtopics":[
        {
          "order": 1,
          "name": (Give a brief name to the subtopic maximum 5 words),
          "objectives": (Give a list of objectives to fulfill this topic divided by -),
          "description": (Give a description about the subtopic),
          "summary": (Give a brief explanation about the topic and what the user is going to learn),
        },
        ...
        ,
        {
          "order": n,
          "name": (Give a brief name to the subtopic maximum 5 words),
          "objectives": (Give a list of objectives to fulfill this topic divided by -),
          "description": (Give a description about the subtopic),
          "summary": (Give a brief explanation about the topic and what the user is going to learn),
        },
      ]
    }
    Keep on mind that the last subtopic must be the practice module about all the 
    topic.
    ''';
  }

  String getChatPrompt(String language, String classTopicObjective, List<Message> messageHistory) {
    final List<Map<String, String>> messages = messageHistory.map((message) {
      return {
        'role': message.isUser ? 'user' : 'system',
        'message': message.text,
      };
    }).toList();
    print("Mensajes");
    print(json.encode(messages));
    // Creamos el prompt
    final String prompt = '''
    You are a $language teacher. Your objective is to achieve the following goal: $classTopicObjective.
    You will have conversations with the user, who is your student, to ensure their learning.
    Always respond in JSON format and in the language that you teach.
    Additionally, include in the JSON response whether the student has achieved the objective from your perspective with the variable 'success' as 'true' or 'false'.
    here is an example of how you should respond if the user hasn't completed the goal from your perspective yet {'success':'false', 'message':'{your response}'}.
    ONLY RETURN THE JSON, DON'T ADD ANY OTHER THING (for example not return json{...} or like that).
    Messages history: ${json.encode(messages)}
    ''';

    return prompt;
  }
}
