import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/entities/subtopic.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
import 'package:gemini_proyect/domain/services/subtopic_service.dart';

import '../chat/chat_screen.dart';

class StepsScreen extends StatefulWidget {
  final List<Subtopic> steps;
  final String classTopicName;
  final IChatMessageService chatMessageService;
  final ConceptService conceptService;
  final SubtopicService subtopicService;

  const StepsScreen({
    super.key,
    required this.steps,
    required this.classTopicName,
    required this.chatMessageService,
    required this.conceptService,
    required this.subtopicService,
  });

  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  late List<Subtopic> steps;

  @override
  void initState() {
    super.initState();
    steps = widget.steps;
  }

  void updateSteps(List<Subtopic> newSteps) {
    setState(() {
      steps = newSteps;
    });
  }

  Future<void> _refreshSteps() async {
    // Aquí debes obtener los datos actualizados de tu fuente de datos, por ejemplo, una llamada a la base de datos o a un servicio.
    // Supongamos que obtienes los datos de un servicio:
    List<Subtopic> updatedSteps = await widget.subtopicService.getSubtopicsByTopicId(steps.first.topicId);
    updateSteps(updatedSteps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classTopicName),
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
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7.0),
                            topRight: Radius.circular(7.0)),
                      ),
                      child: Text(
                        '${steps[index].order}. ${steps[index].name}',
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
                        steps[index].summary,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              if (steps[index].isUnlocked) {
                                return Colors.deepPurple; // Color cuando el subtema está desbloqueado
                              } else {
                                return Colors.grey[300]!; // Color cuando el subtema está bloqueado
                              }
                            },
                          ),
                        ),
                        onPressed: steps[index].isUnlocked
                            ? () async {
                          // Navegar a ChatScreen y esperar el resultado
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                classTopic: Subtopic(
                                  id: steps[index].id,
                                  name: steps[index].name,
                                  description: steps[index].description,
                                  objectives: steps[index].objectives,
                                  summary: steps[index].summary,
                                  completed: steps[index].completed,
                                  order: steps[index].order,
                                  isUnlocked: steps[index].isUnlocked,
                                  topicId: steps[index].topicId,
                                ),
                                chatMessageService:
                                widget.chatMessageService,
                                conceptService: widget.conceptService,
                                subtopicService: widget.subtopicService,
                              ),
                            ),
                          );

                          // Actualizar los pasos al regresar de ChatScreen
                          await _refreshSteps();
                        }
                            : null, // Deshabilita el botón si el subtema está bloqueado
                        child: Text(
                          'Go to Chat',
                          style: TextStyle(color: Colors.grey[50]),
                        ),
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
