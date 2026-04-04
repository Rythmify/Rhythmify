import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/usecases/is_blocked_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

final isBlockedProvider = FutureProvider.family<bool, String>((ref, participantId) async {
    final uCase = IsBlockedUsecase(repo:ref.read(repositoryprovider));
    final isBlocked =await uCase(participantId);
    return isBlocked;
  }
);