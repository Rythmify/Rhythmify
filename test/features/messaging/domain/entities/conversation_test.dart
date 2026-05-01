import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

/// Tests for the [Conversation] domain entity.
///
/// Verifies field storage, optional [participantAvatar] nullability,
/// zero [unReadCount], and [copyWith] immutability behaviour.
void main() {
  final tDate = DateTime(2024, 6, 1, 10, 30);

  final tConversation = Conversation(
    conversationId: 'conv-1',
    participantId: 'user-2',
    participantName: 'Alice',
    participantAvatar: 'https://example.com/avatar.png',
    lastMessagePreview: 'Hey there',
    lastMessageDate: tDate,
    unReadCount: 3,
  );

  group('Conversation', () {
    test('stores all fields correctly', () {
      expect(tConversation.conversationId, 'conv-1');
      expect(tConversation.participantId, 'user-2');
      expect(tConversation.participantName, 'Alice');
      expect(tConversation.participantAvatar, 'https://example.com/avatar.png');
      expect(tConversation.lastMessagePreview, 'Hey there');
      expect(tConversation.lastMessageDate, tDate);
      expect(tConversation.unReadCount, 3);
    });

    test('participantAvatar is null when not provided', () {
      final c = Conversation(
        conversationId: 'conv-2',
        participantId: 'user-3',
        participantName: 'Bob',
        lastMessagePreview: 'Hi',
        lastMessageDate: tDate,
        unReadCount: 0,
      );
      expect(c.participantAvatar, isNull);
    });

    test('unReadCount can be zero', () {
      final c = Conversation(
        conversationId: 'conv-3',
        participantId: 'user-4',
        participantName: 'Charlie',
        lastMessagePreview: '',
        lastMessageDate: tDate,
        unReadCount: 0,
      );
      expect(c.unReadCount, 0);
    });

    group('copyWith', () {
      test('updates participantName', () {
        final updated = tConversation.copyWith(participantName: 'Bob');
        expect(updated.participantName, 'Bob');
        expect(updated.conversationId, tConversation.conversationId);
        expect(updated.participantId, tConversation.participantId);
        expect(updated.lastMessagePreview, tConversation.lastMessagePreview);
        expect(updated.lastMessageDate, tConversation.lastMessageDate);
        expect(updated.unReadCount, tConversation.unReadCount);
      });

      test('preserves participantName when not provided', () {
        final updated = tConversation.copyWith();
        expect(updated.participantName, 'Alice');
      });

      test('returns a different instance', () {
        final updated = tConversation.copyWith(participantName: 'Dave');
        expect(identical(updated, tConversation), false);
      });
    });
  });
}
