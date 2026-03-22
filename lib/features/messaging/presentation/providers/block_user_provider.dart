import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_notifier.dart';

final blockUserProvider=StateNotifierProvider<BlockUserNotifier,bool>((ref){
  return BlockUserNotifier(ref: ref);
});