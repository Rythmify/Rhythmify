import 'package:flutter/material.dart';

/// Displays available home screen widgets the user can add.
/// Shows two image cards: "Your likes" widget and "Player" widget.

class AddWidgetScreen extends StatelessWidget {
  const AddWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add widgets'), centerTitle: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              'Select a widget to add to home screen',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
          const SizedBox(height: 8),
          _buildCard(
            context: context,
            key: Key('add_you_likes_widget'),
            imgPath: 'assets/images/likes_widget.jpeg',
            height: 250,
          ),
          const SizedBox(height: 15),
          _buildCard(
            context: context,
            key: Key('add_player_widget'),
            imgPath: 'assets/images/player_widget.jpeg',
            height: 210,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Key key,
    required String imgPath,
    required double height,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(splashFactory: InkRipple.splashFactory),
        child: InkWell(
          key: key,
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imgPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
