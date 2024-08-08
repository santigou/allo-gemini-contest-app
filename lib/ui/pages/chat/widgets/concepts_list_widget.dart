import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/entities/concept.dart';

class ConceptsPopup extends StatelessWidget {
  final List<Concept> concepts;

  const ConceptsPopup({Key? key, required this.concepts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: concepts.length,
      itemBuilder: (context, index) {
        final concept = concepts[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(concept.explanation),
                const SizedBox(height: 8),
                Text("Examples: ${concept.examples}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
