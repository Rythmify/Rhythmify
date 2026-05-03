import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_searched_users_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Provider for searching users based on a [query] string.
///
/// This provider uses [GetSearchedUsersUsecase] to filter potential chat
/// participants matching the provided query. Returns an empty list if
/// the query is empty.
///
/// Depends on [repositoryprovider].
final getSearchedUsersProvider =
    FutureProvider.family<List<PotentialConversation>, String>((
      ref,
      query,
    ) async {
      if (query.length < 2) return [];
      final uCase = GetSearchedUsersUsecase(repo: ref.read(repositoryprovider));
      final searchedUsers = await uCase(query);
      return searchedUsers;
    });
