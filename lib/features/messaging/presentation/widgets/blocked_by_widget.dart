import 'package:flutter/material.dart';

class BlockedByWidget extends StatelessWidget {
  const BlockedByWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsGeometry.fromLTRB(24, 16, 24, 67),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This account has disabled messaging for them. \nYou can\'t send messages to this account.',
            style: TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35
            ),
          )
        ],
      ),
    );
  }
}