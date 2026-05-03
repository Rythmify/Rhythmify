import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/notification_prefs_notifier.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_tile_widget.dart';

void _showMessagesFromSheet(
  BuildContext context,
  NotificationPreferencesEntity prefs,
  void Function(NotificationPreferencesEntity) save,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF3A3A3A),
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'New message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MessagesFromOption(
              label: 'Off',
              value: MessagesFrom.nobody,
              current: prefs.messagesFrom,
              onTap: () {
                save(prefs.copyWith(messagesFrom: MessagesFrom.nobody));
                Navigator.pop(context);
              },
            ),
            _MessagesFromOption(
              label: 'From people I follow',
              value: MessagesFrom.followersOnly,
              current: prefs.messagesFrom,
              onTap: () {
                save(prefs.copyWith(messagesFrom: MessagesFrom.followersOnly));
                Navigator.pop(context);
              },
            ),
            _MessagesFromOption(
              label: 'From everyone',
              value: MessagesFrom.everyone,
              current: prefs.messagesFrom,
              onTap: () {
                save(prefs.copyWith(messagesFrom: MessagesFrom.everyone));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'If you have disabled "Receive messages from anyone" in your '
              'inbox settings, you will only ever receive messages and '
              'notifications from people you follow.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    },
  );
}

class _MessagesFromOption extends StatelessWidget {
  final String label;
  final MessagesFrom value;
  final MessagesFrom current;
  final VoidCallback onTap;

  const _MessagesFromOption({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.white)
          : null,
      onTap: onTap,
    );
  }
}

bool _allPushEnabled(NotificationPreferencesEntity p) =>
    p.newFollowerPush &&
    p.repostOfYourPostPush &&
    p.newPostByFollowedPush &&
    p.likesAndPlaysPush &&
    p.commentOnPostPush;

bool _allEmailEnabled(NotificationPreferencesEntity p) =>
    p.newFollowerEmail &&
    p.repostOfYourPostEmail &&
    p.newPostByFollowedEmail &&
    p.likesAndPlaysEmail &&
    p.newMessageEmail &&
    p.commentOnPostEmail;

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications settings'),
        centerTitle: false,
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (prefs) {
          void save(NotificationPreferencesEntity updated) =>
              ref.read(notificationPrefsProvider.notifier).save(updated);

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Push notifications',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SwitchTileWidget(
                key: const Key('push_enable_all'),
                title: 'Enable all',
                subtitle:
                    'Turn on all mobile notifications or select which to receive.',
                initSwitchValue: _allPushEnabled(prefs),
                onSwitchChanged: (value) => save(
                  prefs.copyWith(
                    newFollowerPush: value,
                    repostOfYourPostPush: value,
                    newPostByFollowedPush: value,
                    likesAndPlaysPush: value,
                    commentOnPostPush: value,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_new_follower'),
                title: 'New follower',
                initSwitchValue: prefs.newFollowerPush,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(newFollowerPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_repost_of_your_post'),
                title: 'Repost of your post',
                initSwitchValue: prefs.repostOfYourPostPush,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(repostOfYourPostPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_new_post_by_followed_user'),
                title: 'New post by followed user',
                initSwitchValue: prefs.newPostByFollowedPush,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(newPostByFollowedPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_like_on_your_post'),
                title: 'Like on your post',
                initSwitchValue: prefs.likesAndPlaysPush,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(likesAndPlaysPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_comment_on_your_post'),
                title: 'Comment on your post',
                initSwitchValue: prefs.commentOnPostPush,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(commentOnPostPush: value)),
              ),
              SettingsOptionsTileWidget(
                key: const Key('new_message'),
                title: 'New message',
                onTap: () => _showMessagesFromSheet(context, prefs, save),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Email notifications',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SwitchTileWidget(
                key: const Key('email_enable_all'),
                title: 'Enable all',
                subtitle:
                    'Turn on all email notifications or select which to receive.',
                initSwitchValue: _allEmailEnabled(prefs),
                onSwitchChanged: (value) => save(
                  prefs.copyWith(
                    newFollowerEmail: value,
                    repostOfYourPostEmail: value,
                    newPostByFollowedEmail: value,
                    likesAndPlaysEmail: value,
                    newMessageEmail: value,
                    commentOnPostEmail: value,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_new_follower'),
                title: 'New follower',
                initSwitchValue: prefs.newFollowerEmail,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(newFollowerEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_repost_of_your_post'),
                title: 'Repost of your post',
                initSwitchValue: prefs.repostOfYourPostEmail,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(repostOfYourPostEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_new_post_by_followed_user'),
                title: 'New post by followed user',
                initSwitchValue: prefs.newPostByFollowedEmail,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(newPostByFollowedEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_like_on_your_post'),
                title: 'Like on your post',
                initSwitchValue: prefs.likesAndPlaysEmail,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(likesAndPlaysEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_new_message'),
                title: 'New message',
                initSwitchValue: prefs.newMessageEmail,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(newMessageEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_comment_on_your_post'),
                title: 'Comment on your post',
                initSwitchValue: prefs.commentOnPostEmail,
                onSwitchChanged: (value) =>
                    save(prefs.copyWith(commentOnPostEmail: value)),
              ),
            ],
          );
        },
      ),
    );
  }
}
