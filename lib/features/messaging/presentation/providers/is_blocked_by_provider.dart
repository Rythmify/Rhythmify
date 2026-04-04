import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/usecases/is_blocked_by_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

final isBlockedByProvider = FutureProvider.family<bool, String>((ref, participantId) async {
    final uCase = IsBlockedByUsecase(repo:ref.read(repositoryprovider));
    final isBlockedBy =await uCase(participantId);
    return isBlockedBy;
  }
);