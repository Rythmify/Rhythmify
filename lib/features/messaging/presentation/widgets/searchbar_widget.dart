import 'package:flutter/material.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';

class SearchBarWidget extends StatelessWidget{
    final TextEditingController controller;
    final void Function(String)? onChanged; 

    const SearchBarWidget({
        super.key,
        required this.controller,
        this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color:const Color(0xFF2F2F2F),
                borderRadius: BorderRadius.circular(24)
            ),
            height: 48,
            child: TextField(
                key: const Key('messaging_search_text_field'),
                controller: controller,
                onChanged: onChanged,
                cursorColor: MessagingThemes.msgSearchCursorColor,
                cursorWidth: 2,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      key: const Key('messaging_search_clear_icon_button'),
                      onPressed: (){
                        controller.clear();
                        onChanged?.call('');
                      },
                      icon: Icon(Icons.close)
                    )
                ),
            ),
        );
    }
}