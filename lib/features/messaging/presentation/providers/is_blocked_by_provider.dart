import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/usecases/is_blocked_by_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// A [FutureProvider] that checks if the current user has been blocked by [participantId].
///
/// Returns `true` if blocked by, `false` otherwise.
/// Used in [ChatScreen] to conditionally show [BlockedByWidget].

final isBlockedByProvider = FutureProvider.family<bool, String>((
  ref,
  participantId,
) async {
  final uCase = IsBlockedByUsecase(repo: ref.read(repositoryprovider));
  final isBlockedBy = await uCase(participantId);
  return isBlockedBy;
});
