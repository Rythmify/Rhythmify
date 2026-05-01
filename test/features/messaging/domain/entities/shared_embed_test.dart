import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';

/// Tests for the [SharedEmbed] domain entity.
///
/// Verifies required field storage, optional field nullability, and that
/// all three embed types (track, playlist, album) are accepted by the constructor.
void main() {
  group('SharedEmbed', () {
    test('stores required fields', () {
      final embed = SharedEmbed(
        embedId: 'track-1',
        embedType: 'track',
        embedName: 'Song Title',
      );
      expect(embed.embedId, 'track-1');
      expect(embed.embedType, 'track');
      expect(embed.embedName, 'Song Title');
    });

    test('optional fields default to null', () {
      final embed = SharedEmbed(
        embedId: 'track-1',
        embedType: 'track',
        embedName: 'Song Title',
      );
      expect(embed.artistName, isNull);
      expect(embed.thumbnailUrl, isNull);
    });

    test('stores all optional fields when provided', () {
      final embed = SharedEmbed(
        embedId: 'pl-1',
        embedType: 'playlist',
        embedName: 'My Playlist',
        artistName: 'DJ Bob',
        thumbnailUrl: 'https://example.com/thumb.png',
      );
      expect(embed.artistName, 'DJ Bob');
      expect(embed.thumbnailUrl, 'https://example.com/thumb.png');
    });

    test('supports album embedType', () {
      final embed = SharedEmbed(
        embedId: 'alb-1',
        embedType: 'album',
        embedName: 'Great Album',
      );
      expect(embed.embedType, 'album');
    });
  });
}
