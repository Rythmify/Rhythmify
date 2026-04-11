import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/track/data/datasources/track_local_data_source.dart';

void main() {
  late TrackLocalDataSourceImpl dataSource;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    dataSource = TrackLocalDataSourceImpl();
  });

  group('TrackLocalDataSourceImpl', () {
    test('getWaveform returns predefined waveform data', () async {
      final result = await dataSource.getWaveform('track-123');

      expect(result['data']['track_id'], 'track-123');
      expect(result['data']['peaks'], isA<List<dynamic>>());
      expect((result['data']['peaks'] as List).length, 12);
    });

    test('getTags returns predefined tag data', () async {
      final result = await dataSource.getTags();

      expect(result['message'], 'Tags fetched successfully.');
      expect(result['data']['items'], isA<List<dynamic>>());
      expect((result['data']['items'] as List).length, 2);
    });
  });
}
