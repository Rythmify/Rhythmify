import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Notifier that manages the state of marking messages as read.
///
/// The state ([bool]) represents whether an operation to mark a message as read
/// is currently in progress (`true` for loading, `false` otherwise).
///
/// Depends on [repositoryprovider] and [messageProvider].
class MarkAsReadNotifier extends StateNotifier<bool> {
  final Ref ref;
  MarkAsReadNotifier({required this.ref}) : super(false);

  /// Marks a specific [msgId] as read within a given [convId].
  ///
  /// Side effects:
  /// - Updates the local state to `true` during the operation.
  /// - Invalidates [messageProvider] for the specified conversation upon success.
  /// - Syncs with the [RemoteDataSource] via the repository.
  Future<void> markRead({required String msgId, required String convId}) async {
    state = true;
    final uCase = MarkMessagesAsReadUsecase(repo: ref.read(repositoryprovider));
    await uCase(msgId, convId);
    ref.invalidate(messagesNotifierProvider(convId));
    state = false;
  }
}
