import 'package:flutter/material.dart';

class SearchMessageWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  const SearchMessageWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('messaging_search_message_elevated_button'),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      child: Text(
        'Message',
        key: const Key('messaging_search_message_text'),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
