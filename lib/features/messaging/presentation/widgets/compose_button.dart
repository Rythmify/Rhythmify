import 'package:flutter/material.dart';

class ComposeButton extends StatelessWidget {
  const ComposeButton({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      onPressed: (){},
      shape: const CircleBorder(),
      child: const Icon(Icons.edit_outlined),
    );
  }
}