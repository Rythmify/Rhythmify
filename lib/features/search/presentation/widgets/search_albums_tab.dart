import 'package:flutter/material.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // scaffold — wire up when teammate's Album model is ready
    return Center(
      child: Text('No albums found', style: TextStyle(color: Colors.grey[600])),
    );
  }
}
