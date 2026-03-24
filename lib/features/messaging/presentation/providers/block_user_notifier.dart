import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/usecases/block_user_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Notifier that manages the state of blocking a user.
///
/// The state ([bool]) represents whether a block operation is currently
/// in progress (`true` for loading, `false` otherwise).
///
/// Depends on [repositoryprovider].
class BlockUserNotifier extends StateNotifier<bool> {
  final Ref ref;
  BlockUserNotifier({required this.ref}) : super(false);

  /// Blocks a user identified by [participantId].
  ///
  /// Side effects:
  /// - Updates the local state to `true` during the operation.
  /// - Syncs with the [RemoteDataSource] via [BlockUserUsecase].
  Future<void> blockUser({required String participantId}) async {
    state = true;
    final uCase = BlockUserUsecase(repo: ref.read(repositoryprovider));
    await (uCase(participantId));
    state = false;
  }
}
