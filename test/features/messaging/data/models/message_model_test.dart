import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';

void main() {
  final tDate = DateTime.parse('2024-06-01T12:00:00.000Z');

  final tJson = <String, dynamic>{
    'id': 'msg-1',
    'conversation_id': 'conv-1',
    'sender_id': 'user-1',
    'body': 'Hello world',
    'embed_id': null,
    'embed_type': null,
    'is_read': false,
    'created_at': '2024-06-01T12:00:00.000Z',
  };

  group('MessageModel', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final model = MessageModel.fromJson(tJson);
        expect(model.messageId, 'msg-1');
        expect(model.conversationId, 'conv-1');
        expect(model.senderId, 'user-1');
        expect(model.body, 'Hello world');
        expect(model.embedId, isNull);
        expect(model.embedType, isNull);
        expect(model.isRead, false);
        expect(model.createdAt, tDate);
      });

      test('parses embed fields when present', () {
        final json = Map<String, dynamic>.from(tJson)
          ..['embed_id'] = 'track-123'
          ..['embed_type'] = 'track';
        final model = MessageModel.fromJson(json);
        expect(model.embedId, 'track-123');
        expect(model.embedType, 'track');
      });

      test('parses isRead as true', () {
        final json = Map<String, dynamic>.from(tJson)..['is_read'] = true;
        expect(MessageModel.fromJson(json).isRead, true);
      });

      test('parses createdAt correctly from ISO 8601 string', () {
        final model = MessageModel.fromJson(tJson);
        expect(model.createdAt, tDate);
      });

      test('parses null body correctly', () {
        final json = Map<String, dynamic>.from(tJson)..['body'] = null;
        expect(MessageModel.fromJson(json).body, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields with correct keys', () {
        final model = MessageModel(
          messageId: 'msg-1',
          conversationId: 'conv-1',
          senderId: 'user-1',
          body: 'Hello world',
          isRead: false,
          createdAt: tDate,
        );
        final json = model.toJson();
        expect(json['id'], 'msg-1');
        expect(json['conversation_id'], 'conv-1');
        expect(json['sender_id'], 'user-1');
        expect(json['body'], 'Hello world');
        expect(json['embed_id'], isNull);
        expect(json['embed_type'], isNull);
        expect(json['is_read'], false);
        expect(json['created_at'], tDate.toIso8601String());
      });

      test('serializes embed fields when present', () {
        final model = MessageModel(
          messageId: 'msg-2',
          conversationId: 'conv-1',
          senderId: 'user-1',
          embedId: 'track-456',
          embedType: 'track',
          isRead: true,
          createdAt: tDate,
        );
        final json = model.toJson();
        expect(json['embed_id'], 'track-456');
        expect(json['embed_type'], 'track');
      });

      test('round-trips through fromJson then toJson', () {
        final model = MessageModel.fromJson(tJson);
        final json = model.toJson();
        expect(json['id'], tJson['id']);
        expect(json['conversation_id'], tJson['conversation_id']);
        expect(json['sender_id'], tJson['sender_id']);
        expect(json['body'], tJson['body']);
        expect(json['is_read'], tJson['is_read']);
      });
    });

    test('is a subtype of Message', () {
      expect(MessageModel.fromJson(tJson), isA<Message>());
    });
  });
}
