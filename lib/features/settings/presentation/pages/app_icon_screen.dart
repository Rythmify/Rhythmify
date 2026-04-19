import 'package:dynamic_app_icon_flutter_plus/dynamic_app_icon_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  _IconOption(name: 'OG', assetPath: 'assets/icons/app_icon_og.png', iconKey: 'AppIconOG'),
  _IconOption(name: 'Chrome', assetPath: 'assets/icons/app_icon_chrome.png', iconKey: 'AppIconChrome', isPremium: true),
  _IconOption(name: 'Rose Gold', assetPath: 'assets/icons/app_icon_rose_gold.png', iconKey: 'AppIconRoseGold', isPremium: true),
  _IconOption(name: 'Silver', assetPath: 'assets/icons/app_icon_silver.png', iconKey: 'AppIconSilver', isPremium: true),
  _IconOption(name: 'Soft Purple', assetPath: 'assets/icons/app_icon_soft_purple.png', iconKey: 'AppIconSoftPurple', isPremium: true),
  _IconOption(name: 'Hot Pink', assetPath: 'assets/icons/app_icon_hot_pink.png', iconKey: 'AppIconHotPink', isPremium: true),
  _IconOption(name: 'Tie-Dye', assetPath: 'assets/icons/app_icon_tie_dye.png', iconKey: 'AppIconTieDye', isPremium: true),
  _IconOption(name: 'Leopard', assetPath: 'assets/icons/app_icon_leopard.png', iconKey: 'AppIconLeopard', isPremium: true),

];

const _prefKey = 'selected_app_icon';

class AppIconScreen extends StatefulWidget {
  const AppIconScreen({super.key});

  @override
  State<AppIconScreen> createState() => _AppIconScreenState();
}

class _AppIconScreenState extends State<AppIconScreen> {
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedKey = prefs.getString(_prefKey);
    });
  }

  Future<void> _selectIcon(_IconOption option) async {
    if (option.isPremium) {
      context.push('/upgrade');
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
              isPremium: option.isPremium,
              isSelected: _selectedKey == option.iconKey,
              onTap: () => _selectIcon(option),
            );
          },
        ),
      ),
    );
  }
}
