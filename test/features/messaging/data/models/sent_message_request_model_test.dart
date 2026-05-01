import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/models/sent_message_request_model.dart';

void main() {
  group('SentMessageRequestModel', () {
    group('toJson', () {
      test('returns only body when only body is set', () {
        final model = SentMessageRequestModel(body: 'Hello world');
        final json = model.toJson();
        expect(json['body'], 'Hello world');
        expect(json.containsKey('resource'), false);
      });

      test('returns resource with type track when embedType is track', () {
        final model = SentMessageRequestModel(
          embedId: 'track-123',
          embedType: 'track',
        );
        final json = model.toJson();
        expect(json.containsKey('body'), false);
        expect(json['resource'], {'type': 'track', 'id': 'track-123'});
      });

      test('returns resource with type playlist when embedType is playlist', () {
        final model = SentMessageRequestModel(
          embedId: 'pl-456',
          embedType: 'playlist',
        );
        final json = model.toJson();
        expect(json['resource'], {'type': 'playlist', 'id': 'pl-456'});
      });

      test('returns resource with type playlist when embedType is album', () {
        final model = SentMessageRequestModel(
          embedId: 'alb-789',
          embedType: 'album',
        );
        final json = model.toJson();
        expect(json['resource'], {'type': 'playlist', 'id': 'alb-789'});
      });

      test('includes both body and resource when both are set', () {
        final model = SentMessageRequestModel(
          body: 'Check this out',
          embedId: 'track-999',
          embedType: 'track',
        );
        final json = model.toJson();
        expect(json['body'], 'Check this out');
        expect(json['resource'], {'type': 'track', 'id': 'track-999'});
      });

      test('returns empty map when all fields are null', () {
        final model = SentMessageRequestModel();
        expect(model.toJson(), isEmpty);
      });

      test('does not include resource when embedId is null even if embedType is set', () {
        final model = SentMessageRequestModel(embedType: 'track');
        final json = model.toJson();
        expect(json.containsKey('resource'), false);
      });
    });

    test('all fields are optional in constructor', () {
      expect(() => SentMessageRequestModel(), returnsNormally);
    });
  });
}
