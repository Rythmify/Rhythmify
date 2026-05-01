import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';

void main() {
  final tDate = DateTime(2024, 6, 1, 12, 0, 0);

  final tMessage = Message(
    messageId: 'msg-1',
    senderId: 'user-1',
    conversationId: 'conv-1',
    body: 'Hello',
    isRead: false,
    createdAt: tDate,
  );

  group('Message', () {
    test('stores all required fields correctly', () {
      expect(tMessage.messageId, 'msg-1');
      expect(tMessage.senderId, 'user-1');
      expect(tMessage.conversationId, 'conv-1');
      expect(tMessage.body, 'Hello');
      expect(tMessage.isRead, false);
      expect(tMessage.createdAt, tDate);
    });

    test('optional fields default to null', () {
      expect(tMessage.embedId, isNull);
      expect(tMessage.embedType, isNull);
    });

    test('stores embed fields when provided', () {
      final m = Message(
        messageId: 'msg-2',
        senderId: 'user-1',
        conversationId: 'conv-1',
        embedId: 'track-123',
        embedType: 'track',
        isRead: true,
        createdAt: tDate,
      );
      expect(m.embedId, 'track-123');
      expect(m.embedType, 'track');
      expect(m.body, isNull);
    });

    group('copyWith', () {
      test('returns new message with updated isRead', () {
        final updated = tMessage.copyWith(isRead: true);
        expect(updated.isRead, true);
        expect(updated.messageId, tMessage.messageId);
        expect(updated.senderId, tMessage.senderId);
        expect(updated.conversationId, tMessage.conversationId);
        expect(updated.body, tMessage.body);
        expect(updated.embedId, tMessage.embedId);
        expect(updated.embedType, tMessage.embedType);
        expect(updated.createdAt, tMessage.createdAt);
      });

      test('preserves isRead when not provided', () {
        final updated = tMessage.copyWith();
        expect(updated.isRead, false);
      });

      test('returns a different instance', () {
        final updated = tMessage.copyWith(isRead: true);
        expect(identical(updated, tMessage), false);
      });

      test('can toggle isRead to false', () {
        final readMsg = Message(
          messageId: 'msg-3',
          senderId: 'user-1',
          conversationId: 'conv-1',
          isRead: true,
          createdAt: tDate,
        );
        final updated = readMsg.copyWith(isRead: false);
        expect(updated.isRead, false);
      });
    });
  });
}
