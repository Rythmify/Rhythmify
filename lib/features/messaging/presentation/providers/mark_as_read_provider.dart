import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_notifier.dart';

final markAsRead=StateNotifierProvider<MarkAsReadNotifier,bool>((ref){
  return MarkAsReadNotifier(ref: ref);
});