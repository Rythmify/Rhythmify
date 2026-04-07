import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/usecases/is_blocked_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// A [FutureProvider] that checks if the current user has blocked [participantId].
///
/// Returns `true` if blocked, `false` otherwise.
/// Used in [ChatScreen] to conditionally show [BlockedUserWidget].

final isBlockedProvider = FutureProvider.family<bool, String>((
  ref,
  participantId,
) async {
  final uCase = IsBlockedUsecase(repo: ref.read(repositoryprovider));
  final isBlocked = await uCase(participantId);
  return isBlocked;
});
