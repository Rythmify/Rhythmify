import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A styled text input widget for composing messages in the chat.
///
/// Supports multiline input. On desktop/web, Enter sends the message
/// (via [onSubmitted]) and Shift+Enter adds a newline. On mobile,
/// the "Send" action on the keyboard triggers [onSubmitted].
class MessageInputBubble extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  const MessageInputBubble({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  State<MessageInputBubble> createState() => _MessageInputBubbleState();
}

class _MessageInputBubbleState extends State<MessageInputBubble> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        // Handle both regular Enter and Numpad Enter
        final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter;

        if (isEnter && !HardwareKeyboard.instance.isShiftPressed) {
          // We handle KeyDown to trigger the action.
          // We also handle KeyRepeat to prevent newlines if the key is held.
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            if (widget.onSubmitted != null &&
                widget.controller.text.trim().isNotEmpty) {
              widget.onSubmitted!(widget.controller.text);
            }
            return KeyEventResult.handled;
          }
          // Handle KeyUp to also prevent default behavior
          if (event is KeyUpEvent) {
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(26),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        key: const Key('messaging_message_input_text_field'),
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: 3,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.send,
        onFieldSubmitted: widget.onSubmitted,
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
