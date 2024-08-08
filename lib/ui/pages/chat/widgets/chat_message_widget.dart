import 'package:flutter/material.dart';

import '../../../../domain/services/message_service.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;
  final Future<void> Function({int? messageId}) onConceptPressed;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.onConceptPressed,
  });

  @override
  Widget build(BuildContext context) {
    return (message.isUser) ?
      Text(
        message.text,
        style: const TextStyle(color: Colors.white),
      ) : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.info, color: Colors.white),
          onPressed: () {
            onConceptPressed(messageId: message.id);
          },
        )
      ],
    );
  }
}
