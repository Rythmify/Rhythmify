import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class BottomSheetContainer extends StatelessWidget {
  final Widget child;

  const BottomSheetContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add this BoxConstraints to calculate screen height minus 50px
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 50,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(child: child),
    );
  }
}
