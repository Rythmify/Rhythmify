import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_notifier.dart';

final sendMessageProvider=StateNotifierProvider<SendMessageNotifier,bool>((ref){
  return SendMessageNotifier(ref: ref);
});