import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/reusable_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications settings'),
        centerTitle: false,
      ),
      body: ListView(
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
          ReusableTileWidget(
            key: const Key('push_enable_all'),
            title: 'Enable all',
            subtitle:
                'Turn on all mobile notifications or select which to receive.',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_new_follower'),
            title: 'New follower',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_repost_of_your_post'),
            title: 'Repost of your post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_new_post_by_followed_user'),
            title: 'New post by followed user',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_like_on_your_post'),
            title: 'Like on your post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_comment_on_your_post'),
            title: 'Comment on your post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_rythmify_feature_updates'),
            title: 'Rythmify feature updates and education',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_surveys'),
            title: 'Surveys and feedback',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_promotional'),
            title: 'Promotional and partnership content',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('push_recommended'),
            title: 'Recommended content',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),

          SettingsOptionsTileWidget(
            key: Key('new_message'),
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
          ReusableTileWidget(
            key: const Key('email_enable_all'),
            title: 'Enable all',
            subtitle:
                'Turn on all email notifications or select which to receive.',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_new_follower'),
            title: 'New follower',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_repost_of_your_post'),
            title: 'Repost of your post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_new_post_by_followed_user'),
            title: 'New post by followed user',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_like_on_your_post'),
            title: 'Like on your post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_new_message'),
            title: 'New message',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_comment_on_your_post'),
            title: 'Comment on your post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_new_group_post'),
            title: 'New group post',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_rythmify_feature_updates'),
            title: 'Rythmify feature updates and education',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_surveys'),
            title: 'Surveys and feedback',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_promotional'),
            title: 'Promotional and partnership content',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_recommended'),
            title: 'Recommended content',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
          const SizedBox(height: 4),
          ReusableTileWidget(
            key: const Key('email_rythmify_newsletter'),
            title: 'Rythmify newsletter',
            switchExists: true,
            initSwitchValue: true,
            onSwitchChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
