import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/confirn_block_widget.dart';

class PopUpMenuWidget extends ConsumerWidget {
  final String participantId;
  const PopUpMenuWidget({
    super.key,
    required this.participantId
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return PopupMenuButton<String>(
      icon:const Icon(Icons.more_vert),
      color:const Color(0xFF2F2F2F),
      onSelected:(value)async{
        if(value=='block')
        {
          final confirmBlock=await showDialog<bool>(context: context,
          builder: (_)=>const ConfirmBlock());
          if(confirmBlock==false)
          {
            await ref.read(blockUserProvider.notifier).blockUser(participantId: participantId);
          }
        }
        else if (value == 'report'){}
      },
      itemBuilder: (context)=>[
        const PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Icon(Icons.block,color: Colors.white),
              SizedBox(width: 12),
              Text('Block Profile',style: TextStyle(color: Colors.white))
            ],
          )
          ),
          const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined,color: Colors.white),
              SizedBox(width: 12),
              Text('Report Profile',style: TextStyle(color: Colors.white))
            ],
          )
          ),
      ],
    );
  }
}