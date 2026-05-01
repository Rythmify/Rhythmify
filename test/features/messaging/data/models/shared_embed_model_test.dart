import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/models/shared_embed_model.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';

void main() {
  group('SharedEmbedModel', () {
    group('fromJson', () {
      test('parses track embed correctly', () {
        final json = {
          'embedId': 'track-1',
          'embedType': 'track',
          'embedName': 'Great Song',
          'artistName': 'Artist X',
          'thumbnailUrl': 'https://example.com/thumb.png',
        };
        final model = SharedEmbedModel.fromJson(json);
        expect(model.embedId, 'track-1');
        expect(model.embedType, 'track');
        expect(model.embedName, 'Great Song');
        expect(model.artistName, 'Artist X');
        expect(model.thumbnailUrl, 'https://example.com/thumb.png');
      });

      test('parses playlist embed correctly', () {
        final json = {
          'embedId': 'pl-2',
          'embedType': 'playlist',
          'embedName': 'Chill Vibes',
          'artistName': 'DJ Cool',
          'thumbnailUrl': 'https://example.com/pl.png',
        };
        final model = SharedEmbedModel.fromJson(json);
        expect(model.embedType, 'playlist');
        expect(model.embedName, 'Chill Vibes');
      });

      test('parses album embed correctly', () {
        final json = {
          'embedId': 'alb-3',
          'embedType': 'album',
          'embedName': 'Epic Album',
          'artistName': 'Band Y',
          'thumbnailUrl': 'https://example.com/alb.png',
        };
        final model = SharedEmbedModel.fromJson(json);
        expect(model.embedType, 'album');
      });
    });

    test('is a subtype of SharedEmbed', () {
      final model = SharedEmbedModel(
        embedId: 'e1',
        embedType: 'track',
        embedName: 'Test Song',
      );
      expect(model, isA<SharedEmbed>());
    });

    test('can be constructed directly with required fields', () {
      final model = SharedEmbedModel(
        embedId: 'e2',
        embedType: 'playlist',
        embedName: 'My Playlist',
      );
      expect(model.artistName, isNull);
      expect(model.thumbnailUrl, isNull);
    });
  });
}
