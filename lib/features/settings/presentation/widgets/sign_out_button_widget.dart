import 'package:flutter/material.dart';

class SignOutButtonWidget extends StatelessWidget{
  const SignOutButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:ElevatedButton(
              key: Key('settings_sign_out_button'),
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Sign out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
          )
    );
  }
  
}