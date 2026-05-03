import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/player/presentation/widgets/track_info_box.dart';
import '../presentation_test_helper.dart';

void main() {
  testWidgets('TrackInfoBox displays title and artist', (tester) async {
    bool navigated = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrackInfoBox(
            trackInfo: testTrack,
            onNavigateBehindTrack: () => navigated = true,
          ),
        ),
      ),
    );

    expect(find.text(testTrack.title), findsOneWidget);
    expect(find.text(testTrack.artist), findsOneWidget);
    expect(find.text('Behind this track'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('player_track_info_box_details_gesturedetector')),
    );
    expect(navigated, true);

    navigated = false;
    await tester.tap(
      find.byKey(
        const Key('player_track_info_box_behind_track_gesturedetector'),
      ),
    );
    expect(navigated, true);
  });
}
