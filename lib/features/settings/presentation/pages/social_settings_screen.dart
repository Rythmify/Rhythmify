import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/reusable_tile_widget.dart';

class SocialSettingsScreen extends StatelessWidget{
  const SocialSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Social settings'), centerTitle: false),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:const EdgeInsets.symmetric(horizontal: 16),
              child:Text(
                'Social networking',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ReusableTileWidget(
              key: const Key('show_comments_tile'),
              title: 'Show comments and reactions on the waveform',
              subtitle: 'Waveform comments and reactions are visible in the fullscreen player',
              switchExists: true,
              initSwitchValue: true,
              onSwitchChanged: (value) {},
            ),
            ReusableTileWidget(
              key: const Key('show_activities_tile'),
              title: 'Show my activities in social discovery playlists and modules',
              subtitle: "Your Likes, Reactions and other engagement may be shown to other users in discovery features such as 'Liked By' playlists or update feeds. Turning this off won't hide your Likes on your profile or tracks.",
              switchExists: true,
              initSwitchValue: true,
              onSwitchChanged: (value) {} ,
            ),
            const SizedBox(height:2),
            Padding(
              padding:const EdgeInsets.symmetric(horizontal: 16),
              child:Text(
                'Insights visibility',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ReusableTileWidget(
              key: const Key('show_top_fan_tile'),
              title: "Show when I'm a First or Top Fan",
              subtitle: 'You will appear in public First Fans and Top Fans lists',
              switchExists: true,
              initSwitchValue: true,
              onSwitchChanged: (value) {},
            )
          ],
        ),
      )
    );
    
  }
}