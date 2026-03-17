import 'package:flutter/material.dart';

class SearchMessageWidget extends StatelessWidget {
  const SearchMessageWidget({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){},
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: StadiumBorder()
      ),
      child: Text('Message',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold
      ),
      )
     );
  }
}