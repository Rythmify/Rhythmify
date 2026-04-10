import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/data/models/track_model.dart';

void main() {
  test('fromJson supports nested user object and stream_url', () {
    final model = TrackModel.fromJson({
      'id': 't1',
      'user': {'id': 'u1', 'display_name': 'Artist'},
      'title': 'Track',
      'stream_url': 'https://stream',
      'duration': 120,
      'created_at': '2026-01-01T00:00:00.000Z',
      'artwork_url': 'cover',
      'play_count': 99,
      'like_count': 5,
      'is_liked': true,
      'is_artist_followed': true,
    });

    expect(model.userId, 'u1');
    expect(model.artist, 'Artist');
    expect(model.audioUrl, 'https://stream');
    expect(model.coverImage, 'cover');
    expect(model.duration.inSeconds, 120);
  });

  test('toJson serializes core fields', () {
    final model = TrackModel.fromJson({
      'id': 't1',
      'user_id': 'u1',
      'title': 'Track',
      'audio_url': 'https://audio',
      'artist': 'A',
      'duration': 30,
      'created_at': '2026-01-01T00:00:00.000Z',
    });

    final json = model.toJson();
    expect(json['id'], 't1');
    expect(json['user_id'], 'u1');
    expect(json['duration'], 30);
  });
}
