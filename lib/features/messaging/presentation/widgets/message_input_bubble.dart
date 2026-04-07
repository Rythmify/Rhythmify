import 'package:flutter/material.dart';

/// A styled text input widget for composing messages in the chat.
///
/// Supports multiline input with newline action. Displays permalink URLs
/// of selected embeds alongside user-typed text. The controller is managed
/// by the parent [ChatScreen] which handles sending and clearing.
class MessageInputBubble extends StatelessWidget {
  final TextEditingController controller;

  const MessageInputBubble({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(26),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        key: const Key('messaging_message_input_text_field'),
        controller: controller,
        maxLines: null,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Type your message',
          hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
