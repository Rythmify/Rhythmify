import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/icon_carousal_widget.dart';

class UpgradeIconScreen extends StatefulWidget {
  const UpgradeIconScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UpgradeIconState();
}


class _UpgradeIconState extends State<UpgradeIconScreen>{
  static const iconPaths=[
    'assets/icons/app_icon_chrome.png',
    'assets/icons/app_icon_rose_gold.png',
    'assets/icons/app_icon_silver.png',
    'assets/icons/app_icon_soft_purple.png',
    'assets/icons/app_icon_hot_pink.png',
    'assets/icons/app_icon_tie_dye.png',
    'assets/icons/app_icon_leopard.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned( //the x icon, top right
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20)
                ),
              )
            ),

            Column( //page content
              children: [
                const SizedBox(height: 60),
                Center( //the icon carousal
                  child: IconCarousalWidget(
                    key: Key('premium_icons_carousal'),
                    iconPaths: iconPaths
                  ),
                ),

                //const Spacer(),
                const SizedBox(height: 130),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom app\nicons to match\nyour style.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          height: 1.1
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Cancel anytime.',
                            style: TextStyle(color: Colors.white,fontSize: 14),
                          ),
                          GestureDetector(
                            onTap:(){},
                            child: const Text(
                              'Restrictions apply',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blueAccent
                              ),
                            ),
                          )
                        ]
                      ),
                      
                      const SizedBox(height: 24),
                      ElevatedButton( //the button
                        key: Key('app_icon_subscribe_button'),
                        onPressed: () => context.push('/upgrade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          elevation: 0
                        ),
                        child: const Text(
                          'Get Premium',
                          style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
                        )
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/upgrade'),
                          child: const Text(
                            'See all plans',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32)
                    ],
                  ),
                )
              ],
            )
          ],
        )
      ),
    );
  }
}