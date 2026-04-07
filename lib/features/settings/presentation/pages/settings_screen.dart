import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: false),
      body: ListView(
        children: [
          SettingsOptionsTileWidget( //1- Import my music
            key: Key('option_Import_my_music'),
            title:'Import my music',
            onTap: (){ context.push('/library/settings/import-my-music');},
          ),
          SettingsOptionsTileWidget( //2- Account
            key: Key('option_Account'),
            title:'Account',
            onTap: (){},
          ),
          SettingsOptionsTileWidget( //3- Upload
            key: Key('option_Upload'),
            title:'Upload',
            onTap: (){},
          ),
          SettingsOptionsTileWidget( //4- Basic settings
            key: Key('option_Basic_settings'),
            title:'Basic settings',
            onTap: (){context.push('/library/settings/basic-settings');},
          ),
          SettingsOptionsTileWidget( //5- Social settings
            key: Key('option_Social_settings'),
            title:'Social settings',
            onTap: (){},
          ),
          SettingsOptionsTileWidget( //6- Inbox
            key: Key('option_Inbox'),
            title:'Inbox',
            onTap: (){context.push('/library/settings/inbox-settings');},
          ),
          SettingsOptionsTileWidget( //7- Notifications
            key: Key('option_Notifications'),
            title:'Notifications',
            onTap: (){},
          ),
          SettingsOptionsTileWidget( //8- Add widgets
            key: Key('option_Add_widgets'),
            title:'Add widgets',
            onTap: (){},
          ),
          const SizedBox(height:24),
          SettingsOptionsTileWidget( //9- Analytics
            key: Key('option_Analytics'),
            title:'Analytics',
            onTap: (){context.push('/library/settings/analytics');},
          ),
          SettingsOptionsTileWidget( //10- Communications
            key: Key('option_Communications'),
            title:'Communications',
            onTap: (){context.push('/library/settings/Communications');},
          ),
          SettingsOptionsTileWidget( //11- Advertising
            key: Key('option_Advertising'),
            title:'Advertising',
            onTap: (){context.push('/library/settings/Advesrtising');},
          ),
          const SizedBox(height: 24),
          SettingsOptionsTileWidget( //12- Support
            key: Key('option_Support'),
            title:'Support',
            onTap: (){},
          ),
          SettingsOptionsTileWidget( //13- Legal
            key: Key('option_Legal'),
            title:'Legal',
            onTap: (){context.push('/library/settings/Legal');},
          ),
          const SizedBox(height: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:ElevatedButton(
                        key: Key('settings_sign_out_button'),
                        onPressed: (){},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2A2A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sign out',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                    )
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  key: const Key('settings_App_version'),
                  'App version 1.0.0\nTroubleshooting id\n498cc2f9-65bf-428e-b283-46530272233e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ),
            ]
          )
        ],
      )
    );
  }
}
