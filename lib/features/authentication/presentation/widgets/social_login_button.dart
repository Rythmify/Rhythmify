import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_theme.dart';

/// Reusable social-provider login button used across auth screens.
enum SocialProvider { google, github, facebook }

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('auth_social_${provider.name}_button'),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: _border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(width: 10),
            Text(
              _label,
              style: AppTheme.labelLarge.copyWith(color: _textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider) {
      case SocialProvider.google:
        return SvgPicture.asset(
          'assets/icons/google_icon.svg',
          height: 20,
          width: 20,
        );
      case SocialProvider.github:
        return const Icon(Icons.code, color: Colors.white, size: 22);
      case SocialProvider.facebook:
        return const Icon(Icons.facebook, color: Colors.white, size: 22);
    }
  }

  Color get _backgroundColor {
    switch (provider) {
      case SocialProvider.google:
        return AppTheme.surface;
      case SocialProvider.github:
        return const Color(0xFF333333);
      case SocialProvider.facebook:
        return const Color(0xFF1877F2);
    }
  }

  Border? get _border {
    switch (provider) {
      case SocialProvider.google:
        return Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3));
      default:
        return null;
    }
  }

  Color get _textColor {
    return Colors.white;
  }

  String get _label {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.github:
        return 'Continue with GitHub';
      case SocialProvider.facebook:
        return 'Continue with Facebook';
    }
  }
}
