import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/sign_out_button_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: false),
      body: ListView(
        children: [
          SettingsOptionsTileWidget(
            //1- Import my music
            key: Key('option_Import_my_music'),
            title: 'Import my music',
            onTap: () {
              context.push('/library/settings/import-my-music');
            },
          ),
          SettingsOptionsTileWidget(
            //2- Account
            key: Key('option_Account'),
            title: 'Account',
            onTap: () {
              context.push('/library/settings/account');
            },
          ),
          SettingsOptionsTileWidget(
            //3- Upload
            key: Key('option_Upload'),
            title: 'Upload',
            onTap: () {},
          ),
          SettingsOptionsTileWidget(
            //4- Basic settings
            key: Key('option_Basic_settings'),
            title: 'Basic settings',
            onTap: () {
              context.push('/library/settings/basic-settings');
            },
          ),
          SettingsOptionsTileWidget(
            //5- Social settings
            key: Key('option_Social_settings'),
            title: 'Social settings',
            onTap: () {
              context.push('/library/settings/social-settings');
            },
          ),
          SettingsOptionsTileWidget(
            //6- Inbox
            key: Key('option_Inbox'),
            title: 'Inbox',
            onTap: () {
              context.push('/library/settings/inbox-settings');
            },
          ),
          SettingsOptionsTileWidget(
            //7- Notifications
            key: Key('option_Notifications'),
            title: 'Notifications',
            onTap: () {
              context.push('/library/settings/notifications');
            },
          ),
          SettingsOptionsTileWidget(
            //8- Add widgets
            key: Key('option_Add_widgets'),
            title: 'Add widgets',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          SettingsOptionsTileWidget(
            //9- Analytics
            key: Key('option_Analytics'),
            title: 'Analytics',
            onTap: () {
              context.push('/library/settings/analytics');
            },
          ),
          SettingsOptionsTileWidget(
            //10- Communications
            key: Key('option_Communications'),
            title: 'Communications',
            onTap: () {
              context.push('/library/settings/Communications');
            },
          ),
          SettingsOptionsTileWidget(
            //11- Advertising
            key: Key('option_Advertising'),
            title: 'Advertising',
            onTap: () {
              context.push('/library/settings/Advesrtising');
            },
          ),
          const SizedBox(height: 24),
          SettingsOptionsTileWidget(
            //12- Support
            key: Key('option_Support'),
            title: 'Support',
            onTap: () {},
          ),
          SettingsOptionsTileWidget(
            //13- Legal
            key: Key('option_Legal'),
            title: 'Legal',
            onTap: () {
              context.push('/library/settings/Legal');
            },
          ),
          const SizedBox(height: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignOutButtonWidget(),
              const SizedBox(height: 16),
              Text(
                key: const Key('settings_App_version'),
                'App version 1.0.0\nTroubleshooting id\n498cc2f9-65bf-428e-b283-46530272233e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
