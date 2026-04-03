import 'package:flutter/material.dart';

class ProfilesTab extends StatelessWidget {
  const ProfilesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // scaffold — wire up when teammate's Profile model is ready
    return Center(
      child: Text(
        'No profiles found',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
