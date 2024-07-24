import 'package:flutter/material.dart';
import 'package:gemini_proyect/ui/pages/playground/chat/chat_screen.dart';

class StepsScreen extends StatelessWidget{
  final List<Map<String, dynamic>> steps;
  final String classTopicName;
  const StepsScreen({super.key, required this.steps, required this.classTopicName});
  //TODO organizar el camino
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classTopicName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25.0),
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7.0), topRight: Radius.circular(7.0))
                      ),
                      child: Text(
                        '${steps[index]['order']}. ${steps[index]['name']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        steps[index]['summary']!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      classTopic: {
                                        'order': steps[index]['order'],
                                        'name': steps[index]['name'],
                                        'summary': steps[index]['summary']
                                      }
                                  )
                              )
                          );
                        },
                        child: const Text('Iniciar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}