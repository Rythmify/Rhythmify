import 'package:flutter/material.dart';

class PrivacyPolicyWidget extends StatelessWidget{
  const PrivacyPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        'Learn more in our Privacy Policy',
        style: TextStyle(color: Colors.blue,fontSize: 14),
      ),
    );
  }
}