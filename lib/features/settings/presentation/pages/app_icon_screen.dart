import 'package:dynamic_app_icon_flutter_plus/dynamic_app_icon_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/icon_tile_widget.dart';

class _IconOption {
  final String name;
  final String assetPath;
  final String? iconKey;
  final bool isPremium;

  const _IconOption({
    required this.name,
    required this.assetPath,
    this.iconKey,
    this.isPremium = false,
  });
}

const List<_IconOption> _icons = [
  _IconOption(name: 'Default', assetPath: 'assets/icons/app_icon.png'),
  _IconOption(
    name: 'OG',
    assetPath: 'assets/icons/app_icon_og.png',
    iconKey: 'AppIconOG',
  ),
  _IconOption(
    name: 'Chrome',
    assetPath: 'assets/icons/app_icon_chrome.png',
    iconKey: 'AppIconChrome',
    isPremium: true,
  ),
  _IconOption(
    name: 'Rose Gold',
    assetPath: 'assets/icons/app_icon_rose_gold.png',
    iconKey: 'AppIconRoseGold',
    isPremium: true,
  ),
  _IconOption(
    name: 'Silver',
    assetPath: 'assets/icons/app_icon_silver.png',
    iconKey: 'AppIconSilver',
    isPremium: true,
  ),
  _IconOption(
    name: 'Soft Purple',
    assetPath: 'assets/icons/app_icon_soft_purple.png',
    iconKey: 'AppIconSoftPurple',
    isPremium: true,
  ),
  _IconOption(
    name: 'Hot Pink',
    assetPath: 'assets/icons/app_icon_hot_pink.png',
    iconKey: 'AppIconHotPink',
    isPremium: true,
  ),
  _IconOption(
    name: 'Tie-Dye',
    assetPath: 'assets/icons/app_icon_tie_dye.png',
    iconKey: 'AppIconTieDye',
    isPremium: true,
  ),
  _IconOption(
    name: 'Leopard',
    assetPath: 'assets/icons/app_icon_leopard.png',
    iconKey: 'AppIconLeopard',
    isPremium: true,
  ),
];

const _prefKey = 'selected_app_icon';

class AppIconScreen extends ConsumerStatefulWidget {
  const AppIconScreen({super.key});

  @override
  ConsumerState<AppIconScreen> createState() => _AppIconScreenState();
}

class _AppIconScreenState extends ConsumerState<AppIconScreen> {
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _loadSelected();
    // Force-refresh subscription every time this screen opens — the provider
    // may have been initialized before the user subscribed and never re-fetched.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumProvider.notifier).loadMySubscription();
    });
  }

  Future<void> _loadSelected() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedKey = prefs.getString(_prefKey);
    });
  }

  Future<void> _selectIcon(_IconOption option) async {
    if (option.isPremium && !ref.read(isPremiumProvider)) {
      context.push('/library/settings/basic-settings/app-icons/premium-apps');
      return;
    }
    if (_selectedKey == option.iconKey) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (option.iconKey == null) {
        await prefs.remove(_prefKey);
      } else {
        await prefs.setString(_prefKey, option.iconKey!);
      }
      await DynamicAppIconFlutterPlus.setAlternateIconName(option.iconKey);
      if (mounted) setState(() => _selectedKey = option.iconKey);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not change app icon')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);
    final userIsPremium = ref.watch(isPremiumProvider);

    if (!premiumState.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('App icon'), centerTitle: false),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF5500),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('App icon'), centerTitle: false),
        body: ListView.builder(
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final option = _icons[index];
            return IconTileWidget(
              name: option.name,
              assetPath: option.assetPath,
              isPremium: option.isPremium && !userIsPremium,
              isSelected: _selectedKey == option.iconKey,
              onTap: () => _selectIcon(option),
            );
          },
        ),
      ),
    );
  }
}
