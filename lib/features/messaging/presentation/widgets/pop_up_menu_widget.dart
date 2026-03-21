import 'package:flutter/material.dart';

class PopUpMenuWidget extends consumerWidget {
  const PopUpMenuWidget({
    super.key
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return PopUpMenuButton<String>(
      icon:const Icon(Icons.more_vert),
      color:const Color(0xFF2F2F2F),
      onSelected:(value)async{
        if(value=='block')
        {}
        else if (value == 'report'){}//TODO
      }
    );
  }
}