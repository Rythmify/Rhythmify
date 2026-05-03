import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_followings_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Provider for fetching the list of users followed by the current user.
///
/// This provider uses [GetFollowingsUsecase] and the authenticated user's ID
/// from [currentUserIdProvider] to retrieve potential chat participants.
///
/// Depends on [repositoryprovider] and [currentUserIdProvider].
final getFollowingsProvider = FutureProvider((ref) async {
  final uCase = GetFollowingsUsecase(repo: ref.read(repositoryprovider));
  final myId = ref.watch(currentUserIdProvider);
  final followings = await uCase(myId);
  return followings;
});
