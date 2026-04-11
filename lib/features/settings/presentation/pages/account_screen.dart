import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/sign_out_button_widget.dart';

/// Displays the user's account information including email address.
/// Provides options to sign out or navigate to account deletion.
/// Uses [ConsumerWidget] to access [AuthNotifier] via Riverpod.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String myEmail = '';

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Scaffold(
          appBar: AppBar(title: const Text('Account'), centerTitle: false),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Email address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                myEmail,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 16),
              SignOutButtonWidget(),
              const SizedBox(height: 8),
              SettingsOptionsTileWidget(
                key: Key('delete_account_button'),
                title: 'Delete account',
                onTap: () {
                  context.push('/library/settings/account/delete-account');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
