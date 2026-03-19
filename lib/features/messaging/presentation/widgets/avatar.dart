import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? img;
  final double radius;

  const Avatar({
    super.key,
    this.img,
    this.radius=20
  });

  @override
  Widget build(BuildContext context) {
    final hasImg=img!=null&&img!.trim().isNotEmpty;
    return CircleAvatar(
      key: const Key('messaging_user_avatar_circle_avatar'),
      radius: radius,
      backgroundColor: const Color(0xFF2B2B2B),
      backgroundImage: hasImg? NetworkImage(img!):null,
      child: !hasImg?
            Icon(
              Icons.person,
              color: const Color(0xFFD0D0D0),
              size:radius
            ):null,
    );
  }
}