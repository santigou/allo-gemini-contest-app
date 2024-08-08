import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/entities/concept.dart';

class ConceptsPopup extends StatelessWidget {
  final List<Concept> concepts;

  const ConceptsPopup({super.key, required this.concepts});

  @override
  Widget build(BuildContext context) {
    return (concepts.isNotEmpty) ? ListView.builder(
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
    ) : Center(child: Text("No Concepts available"),);
  }
}
