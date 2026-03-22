import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserIdProvider=Provider<String>((ref){
  return 'me-000';
});