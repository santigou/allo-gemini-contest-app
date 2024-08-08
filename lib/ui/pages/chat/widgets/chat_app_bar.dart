import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMoreOptionsPressed; // Añadido para el callback

  const ChatAppBar({super.key, required this.title, required this.onMoreOptionsPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Center(
        child: Text(title),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: onMoreOptionsPressed, // Llama al callback
        ),
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}