import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/models/potential_conversation_model.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';

/// Tests for [PotentialConversationModel.fromJson].
///
/// Covers the `id`/`user_id` fallback, optional field defaults, and
/// the intentional omission of the `location` field (pending backend support).
void main() {
  group('PotentialConversationModel', () {
    group('fromJson', () {
      test('parses using id field', () {
        final json = {
          'id': 'user-1',
          'display_name': 'Alice',
          'follower_count': 500,
          'profile_picture': 'https://example.com/alice.png',
        };
        final model = PotentialConversationModel.fromJson(json);
        expect(model.participantId, 'user-1');
        expect(model.participantName, 'Alice');
        expect(model.followersCount, 500);
        expect(model.avatar, 'https://example.com/alice.png');
        expect(model.location, isNull);
      });

      test('falls back to user_id when id is null', () {
        final json = {
          'user_id': 'user-2',
          'display_name': 'Bob',
        };
        final model = PotentialConversationModel.fromJson(json);
        expect(model.participantId, 'user-2');
      });

      test('optional fields default to null when absent', () {
        final json = {
          'id': 'user-3',
          'display_name': 'Charlie',
        };
        final model = PotentialConversationModel.fromJson(json);
        expect(model.followersCount, isNull);
        expect(model.avatar, isNull);
        expect(model.location, isNull);
      });

      test('location is always null (pending backend field)', () {
        final json = {
          'id': 'user-4',
          'display_name': 'Dave',
          'location': 'Cairo',
        };
        final model = PotentialConversationModel.fromJson(json);
        expect(model.location, isNull);
      });

      test('parses zero follower_count', () {
        final json = {
          'id': 'user-5',
          'display_name': 'Eve',
          'follower_count': 0,
        };
        expect(PotentialConversationModel.fromJson(json).followersCount, 0);
      });
    });

    test('is a subtype of PotentialConversation', () {
      final model = PotentialConversationModel(
        participantId: 'user-1',
        participantName: 'Alice',
      );
      expect(model, isA<PotentialConversation>());
    });
  });
}
