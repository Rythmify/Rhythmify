import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../../core/utils/formatters.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/follow_button.dart';

/// A reusable profile card showing avatar, display name, follower count, and a Follow button.
/// Used both in [ProfilesTab] and inline in the All tab's profiles section.
class SearchProfileCard extends StatelessWidget {
  const SearchProfileCard({super.key, required this.profile});
  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/home/profile/${profile.id}'),

      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        backgroundImage: profile.avatarUrl != null
            ? NetworkImage(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        profile.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.person, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            Formatters.formatCount(profile.followersCount),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: FollowButton(targetUserId: profile.id, compact: true),
    );
  }
}

/// Search results tab displaying the profiles list from [searchResultsProvider].
/// Renders a loading spinner, error message, empty state, or a scrollable list of [SearchProfileCard].
class ProfilesTab extends ConsumerWidget {
  const ProfilesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchProfilesProvider);

    return results.when(
      loading: () => const Center(
        key: Key('profiles_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('profiles_error'), child: Text('Error: $e')),
      data: (data) {
        if (data.profiles.isEmpty) {
          return Center(
            key: const Key('profiles_empty'),
            child: Text(
              'No profiles found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.separated(
          key: const Key('profiles_list'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
          itemCount: data.profiles.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => SearchProfileCard(
            key: Key('profile_card_$i'),
            profile: data.profiles[i],
          ),
        );
      },
    );
  }
}
