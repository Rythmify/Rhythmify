import 'package:flutter/material.dart';

class MessageInputBubble extends StatelessWidget{
  final TextEditingController controller;
  final Future<void> Function(String)? onSubmitted;

  const MessageInputBubble({
    super.key,
    required this.controller,
    this.onSubmitted
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(26)
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16
        ),
        decoration: const InputDecoration(
          hintText: 'Type your message',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: 16
          ),
          border: InputBorder.none,
          isCollapsed: true
        ),
      ),
    );
  }
}