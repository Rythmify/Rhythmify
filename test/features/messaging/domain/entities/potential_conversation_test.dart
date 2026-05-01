import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';

/// Tests for the [PotentialConversation] domain entity.
///
/// Verifies required field storage, optional field nullability, and
/// that all optional fields are stored when explicitly provided.
void main() {
  group('PotentialConversation', () {
    test('stores required fields', () {
      final pc = PotentialConversation(
        participantId: 'user-1',
        participantName: 'Alice',
      );
      expect(pc.participantId, 'user-1');
      expect(pc.participantName, 'Alice');
    });

    test('optional fields default to null', () {
      final pc = PotentialConversation(
        participantId: 'user-1',
        participantName: 'Alice',
      );
      expect(pc.followersCount, isNull);
      expect(pc.location, isNull);
      expect(pc.avatar, isNull);
    });

    test('stores all optional fields when provided', () {
      final pc = PotentialConversation(
        participantId: 'user-2',
        participantName: 'Bob',
        followersCount: 1000,
        location: 'Cairo, Egypt',
        avatar: 'https://example.com/bob.png',
      );
      expect(pc.followersCount, 1000);
      expect(pc.location, 'Cairo, Egypt');
      expect(pc.avatar, 'https://example.com/bob.png');
    });

    test('participantId and participantName are required', () {
      expect(
        () => PotentialConversation(participantId: 'x', participantName: 'y'),
        returnsNormally,
      );
    });
  });
}
