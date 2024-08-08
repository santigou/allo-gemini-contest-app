import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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

  String getChatPrompt(String language, String classTopicObjective, List<Message> messageHistory, int level) {
    //TODO: Add the local userLanguage
    String userLanguage = Intl.getCurrentLocale();

    print(userLanguage);

    final List<Map<String, String>> messages = messageHistory.map((message) {
      return {
        'order': (messageHistory.length + 1).toString(),
        'role': message.isUser ? 'user' : 'system',
        'message': message.text,
      };
    }).toList();
    print("Mensajes");
    print(json.encode(messages));
    // Creamos el prompt
    final String prompt = '''
    You are a $language teacher. Your objective is to achieve the following goals:\n$classTopicObjective.
    You will have conversations with the user, who is your student, to ensure their learning.
    your response will be as the following JSON format ONLY RETURN THE JSON, DON'T ADD ANY OTHER THING (for example not return json{...} or like that) :
    {
      message: (Give a message to correct the mistakes or answer to the user, the message depends on the level ($level) 
          1 is Basic this means that most of the message must be on $userLanguage and 
          explaining concepts in this language you must provide examples (max. 3) in the learning languages for the user to answer,
          2 is intermediate the conversations must be most on the learning language also you must provide examples for the user,
          3 is advance the conversation must be most (just exceptions concepts and required user translate) on the learning language but do not provide examples (example: the user asks how do you say grappes? and the language is spanish you can answer "para decir 'grapes' en español you use uvas" this is a concept also),
      concepts:(give a list of new concepts a concept can be new vocabulary, "how to says" ex: My favorite food is ..., grammar topics such us simple past)
      [
        {
          name: (Give the name of the concept, for example: simple past, "My favorite music band is ...", "fireworks",...),
          explanation: (Give the explanation for the respective name, example: simple pas is a grammar time used to explain past,
               this sentence can be use to express something that you like the most,
               this word means "fuegos artificiales" in spanish),
          examples: (give a list of  examples for the respective concept in a string divided by -)         
        }
        ...
      ]
      success: (boolean to express if the subtopic goals were successfully completed)
    }
    Additionally, include in the JSON response whether the student has achieved the objective from your perspective with the variable 'success' as true or false.
    here is an example of how you should respond if the user hasn't completed the goal from your perspective yet {'success':false, 'message':'{your response}'}.
    if there are at least 5 messages and the last message is from the user and it says !finish or /finish you must send a message with something like "you compleated this subtopic manually" and  return success true
    JUST RETURN THE JSON WITHOUT ANY OTHER WORD OR TEXT
    
    WHEN THE  'success' is true the message must close with '...continue in the following subtopic.'
    
    
    
    IMPORTANT CORRECT IN THE NEXT MESSAGE FOR EXAMPLE:
    -if the user is leaning spanish and says something like "yo freir papas en la tarde" 
    you can answer "el modo correcto para decir eso es  'yo frito papas en la tarde'" and you can send the conjugations in the concepts
    -If the user make a mistake you must aks to repeat the sentence
    -Remark the mistake and correct it
    
    Responses examples: Suppose learning Language: Spanish and native language: English 
    
    Message examples:
    * When the user makes a mistake you can answer for example:
    - user message: "Yo pedir una pizza con pina"
      answer message: "Buen trabajo, sin embargo, la forma correcta para decir 'I ask for a pineapple pizza' es 'yo pido una pizza con pina' ..."
    - user message: "El jugar al futbol todos los dias"
      answer message: "Bien hecho, pero la respuesta correcta para expresar 'He plays soccer everyday' es 'El juega futbol todos los dias' ..."
    
    * When you want that the user translate phrases provide the phrases on the native languaje (no matter the level, always on the native languaje):
    - message (level 3): "Por favor traduce las siguientes frases: 1. The kid plays soccer 2. My mom cooks pasta" (same for all levels)
    
    Concepts examples:
    * For conjugations (in case the learning language needs it) use the following concept schema:
    {
      name: 'Querer (presente)',
      explanation: "This verb means 'to want' ..., remember Spanish uses conjugations:
        'Yo quiero ...', 'Tu quieres...', 'El/Ella/Eso quiere...', 'Ustedes/Ellos/Ellas quieren...', 'Nosotros queremos...'"(Add each subject with its conjugation),
      examples: "-Yo quiero comer pizza = I want to eat pizza - El quiere un carro 0 km = He wants a 0 km car -Nosotros queremos jugar futbol = We wanna play soccer"
    }
    
    These are just examples to follow you can add more information in any field
    
    Messages history: ${json.encode(messages)}
    ''';

    return prompt;
  }
}
