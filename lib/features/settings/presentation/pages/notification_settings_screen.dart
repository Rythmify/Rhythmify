import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/notification_prefs_notifier.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_tile_widget.dart';

bool _allPushEnabled(NotificationPreferencesEntity p) =>
    p.newFollowerPush &&
    p.repostOfYourPostPush &&
    p.newPostByFollowedPush &&
    p.likesAndPlaysPush &&
    p.commentOnPostPush &&
    p.featureUpdatesPush &&
    p.surveysAndFeedbackPush &&
    p.promotionalContentPush &&
    p.recommendedContentPush;

bool _allEmailEnabled(NotificationPreferencesEntity p) =>
    p.newFollowerEmail &&
    p.repostOfYourPostEmail &&
    p.newPostByFollowedEmail &&
    p.likesAndPlaysEmail &&
    p.newMessageEmail &&
    p.commentOnPostEmail &&
    p.featureUpdatesEmail &&
    p.surveysAndFeedbackEmail &&
    p.promotionalContentEmail &&
    p.recommendedContentEmail &&
    p.newsletterEmail;

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                subtitle: 'Turn on all mobile notifications or select which to receive.',
                initSwitchValue: _allPushEnabled(prefs),
                onSwitchChanged: (value) => save(prefs.copyWith(
                  newFollowerPush: value,
                  repostOfYourPostPush: value,
                  newPostByFollowedPush: value,
                  likesAndPlaysPush: value,
                  commentOnPostPush: value,
                  featureUpdatesPush: value,
                  surveysAndFeedbackPush: value,
                  promotionalContentPush: value,
                  recommendedContentPush: value,
                )),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_new_follower'),
                title: 'New follower',
                initSwitchValue: prefs.newFollowerPush,
                onSwitchChanged: (value) => save(prefs.copyWith(newFollowerPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_repost_of_your_post'),
                title: 'Repost of your post',
                initSwitchValue: prefs.repostOfYourPostPush,
                onSwitchChanged: (value) => save(prefs.copyWith(repostOfYourPostPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_new_post_by_followed_user'),
                title: 'New post by followed user',
                initSwitchValue: prefs.newPostByFollowedPush,
                onSwitchChanged: (value) => save(prefs.copyWith(newPostByFollowedPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_like_on_your_post'),
                title: 'Like on your post',
                initSwitchValue: prefs.likesAndPlaysPush,
                onSwitchChanged: (value) => save(prefs.copyWith(likesAndPlaysPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_comment_on_your_post'),
                title: 'Comment on your post',
                initSwitchValue: prefs.commentOnPostPush,
                onSwitchChanged: (value) => save(prefs.copyWith(commentOnPostPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_rythmify_feature_updates'),
                title: 'Rythmify feature updates and education',
                initSwitchValue: prefs.featureUpdatesPush,
                onSwitchChanged: (value) => save(prefs.copyWith(featureUpdatesPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_surveys'),
                title: 'Surveys and feedback',
                initSwitchValue: prefs.surveysAndFeedbackPush,
                onSwitchChanged: (value) => save(prefs.copyWith(surveysAndFeedbackPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_promotional'),
                title: 'Promotional and partnership content',
                initSwitchValue: prefs.promotionalContentPush,
                onSwitchChanged: (value) => save(prefs.copyWith(promotionalContentPush: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('push_recommended'),
                title: 'Recommended content',
                initSwitchValue: prefs.recommendedContentPush,
                onSwitchChanged: (value) => save(prefs.copyWith(recommendedContentPush: value)),
              ),
              SettingsOptionsTileWidget(
                key: const Key('new_message'),
                title: 'New message',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                subtitle: 'Turn on all email notifications or select which to receive.',
                initSwitchValue: _allEmailEnabled(prefs),
                onSwitchChanged: (value) => save(prefs.copyWith(
                  newFollowerEmail: value,
                  repostOfYourPostEmail: value,
                  newPostByFollowedEmail: value,
                  likesAndPlaysEmail: value,
                  newMessageEmail: value,
                  commentOnPostEmail: value,
                  featureUpdatesEmail: value,
                  surveysAndFeedbackEmail: value,
                  promotionalContentEmail: value,
                  recommendedContentEmail: value,
                  newsletterEmail: value,
                )),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_new_follower'),
                title: 'New follower',
                initSwitchValue: prefs.newFollowerEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(newFollowerEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_repost_of_your_post'),
                title: 'Repost of your post',
                initSwitchValue: prefs.repostOfYourPostEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(repostOfYourPostEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_new_post_by_followed_user'),
                title: 'New post by followed user',
                initSwitchValue: prefs.newPostByFollowedEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(newPostByFollowedEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_like_on_your_post'),
                title: 'Like on your post',
                initSwitchValue: prefs.likesAndPlaysEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(likesAndPlaysEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_new_message'),
                title: 'New message',
                initSwitchValue: prefs.newMessageEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(newMessageEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_comment_on_your_post'),
                title: 'Comment on your post',
                initSwitchValue: prefs.commentOnPostEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(commentOnPostEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_rythmify_feature_updates'),
                title: 'Rythmify feature updates and education',
                initSwitchValue: prefs.featureUpdatesEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(featureUpdatesEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_surveys'),
                title: 'Surveys and feedback',
                initSwitchValue: prefs.surveysAndFeedbackEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(surveysAndFeedbackEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_promotional'),
                title: 'Promotional and partnership content',
                initSwitchValue: prefs.promotionalContentEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(promotionalContentEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_recommended'),
                title: 'Recommended content',
                initSwitchValue: prefs.recommendedContentEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(recommendedContentEmail: value)),
              ),
              const SizedBox(height: 4),
              SwitchTileWidget(
                key: const Key('email_rythmify_newsletter'),
                title: 'Rythmify newsletter',
                initSwitchValue: prefs.newsletterEmail,
                onSwitchChanged: (value) => save(prefs.copyWith(newsletterEmail: value)),
              ),
            ],
          );
        },
      ),
    );
  }
}
