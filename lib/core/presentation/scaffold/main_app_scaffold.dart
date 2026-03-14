import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

class MainAppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, 
      
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ToDo Later: you will replace this Container with your MiniPlayerWidget()

          Container(
            height: 0, // Set to 60 later when build the player
            // color: Colors.orange.withOpacity(0.2), 
            // alignment: Alignment.center,
            //child: const Text('Mini-Player will go here'),
          ),
          
          BottomNavigation(navigationShell: navigationShell),
        ],
      ),
    );
  }
}