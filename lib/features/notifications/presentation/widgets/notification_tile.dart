import 'package:flutter/material.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget{
  final NotificationType type;
  final VoidCallback? onFollowTap;
  final VoidCallback? onCommentLikeTap;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.type,
    this.onFollowTap,
    this.onCommentLikeTap,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

//helper widgets
Widget _buildHeader(){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Flexible(
        child: Text(
          ''
        )
      )
    ]
  );
}