import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_theme.dart';

enum SocialProvider { google, apple, facebook }

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
      case SocialProvider.apple:
        return const Icon(Icons.apple, color: Colors.white, size: 22);
      case SocialProvider.facebook:
        return const Icon(Icons.facebook, color: Colors.white, size: 22);
    }
  }

  Color get _backgroundColor {
    switch (provider) {
      case SocialProvider.google:
        return AppTheme.surface;
      case SocialProvider.apple:
        return Colors.black;
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
      case SocialProvider.apple:
        return 'Continue with Apple';
      case SocialProvider.facebook:
        return 'Continue with Facebook';
    }
  }
}