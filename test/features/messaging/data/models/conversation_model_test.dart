import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/messaging/data/models/conversation_model.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';

/// Builds a minimal conversation JSON payload for use in [ConversationModel.fromJson] tests.
///
/// All fields have safe defaults; pass overrides to exercise specific branches.
Map<String, dynamic> _buildJson({
  String id = 'conv-1',
  Map<String, dynamic>? participant,
  Map<String, dynamic>? lastMessage,
  int unreadCount = 2,
}) {
  return {
    'id': id,
    'participant': participant ?? {'id': 'user-2', 'display_name': 'Alice'},
    if (lastMessage != null) 'last_message': lastMessage,
    'unread_count': unreadCount,
  };
}

/// Tests for [ConversationModel] JSON serialisation and deserialisation.
///
/// Covers [ConversationModel.fromJson] field parsing, avatar fallback chain,
/// embed-type preview generation, null/missing-key handling, and [toJson] round-trips.
void main() {
  final tDate = DateTime.parse('2024-06-01T12:00:00.000Z');

  final tLastMessage = {
    'body': 'Hey there',
    'created_at': '2024-06-01T12:00:00.000Z',
  };

  group('ConversationModel', () {
    group('fromJson', () {
      test('parses standard fields correctly', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            participant: {
              'id': 'user-2',
              'display_name': 'Alice',
              'profile_picture': 'https://example.com/avatar.png',
            },
            lastMessage: tLastMessage,
          ),
        );
        expect(model.conversationId, 'conv-1');
        expect(model.participantId, 'user-2');
        expect(model.participantName, 'Alice');
        expect(model.participantAvatar, 'https://example.com/avatar.png');
        expect(model.lastMessagePreview, 'Hey there');
        expect(model.lastMessageDate, tDate);
        expect(model.unReadCount, 2);
      });

      test('reads avatar from profile_picture field', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            participant: {
              'id': 'user-2',
              'display_name': 'Alice',
              'profile_picture': 'https://example.com/pp.png',
            },
            lastMessage: tLastMessage,
          ),
        );
        expect(model.participantAvatar, 'https://example.com/pp.png');
      });

      test('falls back to avatar_url when profile_picture is absent', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            participant: {
              'id': 'user-2',
              'display_name': 'Alice',
              'avatar_url': 'https://example.com/avatar_url.png',
            },
            lastMessage: tLastMessage,
          ),
        );
        expect(model.participantAvatar, 'https://example.com/avatar_url.png');
      });

      test(
        'falls back to avatar field when profile_picture and avatar_url absent',
        () {
          final model = ConversationModel.fromJson(
            _buildJson(
              participant: {
                'id': 'user-2',
                'display_name': 'Alice',
                'avatar': 'https://example.com/avatar.png',
              },
              lastMessage: tLastMessage,
            ),
          );
          expect(model.participantAvatar, 'https://example.com/avatar.png');
        },
      );

      test('participantAvatar is null when no avatar key present', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            participant: {'id': 'user-2', 'display_name': 'Alice'},
            lastMessage: tLastMessage,
          ),
        );
        expect(model.participantAvatar, isNull);
      });

      test('uses body as lastMessagePreview when present', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            lastMessage: {
              'body': 'Check this out',
              'created_at': '2024-06-01T12:00:00.000Z',
            },
          ),
        );
        expect(model.lastMessagePreview, 'Check this out');
      });

      test('uses track URL when embed_type is track', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            lastMessage: {
              'embed_id': 'track-999',
              'embed_type': 'track',
              'created_at': '2024-06-01T12:00:00.000Z',
            },
          ),
        );
        expect(
          model.lastMessagePreview,
          'https://rythmify.com/tracks/track-999',
        );
      });

      test('uses playlist URL when embed_type is playlist', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            lastMessage: {
              'embed_id': 'pl-111',
              'embed_type': 'playlist',
              'created_at': '2024-06-01T12:00:00.000Z',
            },
          ),
        );
        expect(
          model.lastMessagePreview,
          'https://rythmify.com/playlists/pl-111',
        );
      });

      test('uses playlist URL when embed_type is album', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            lastMessage: {
              'embed_id': 'alb-222',
              'embed_type': 'album',
              'created_at': '2024-06-01T12:00:00.000Z',
            },
          ),
        );
        expect(
          model.lastMessagePreview,
          'https://rythmify.com/playlists/alb-222',
        );
      });

      test('defaults lastMessagePreview to empty when no body or embed', () {
        final model = ConversationModel.fromJson(
          _buildJson(lastMessage: {'created_at': '2024-06-01T12:00:00.000Z'}),
        );
        expect(model.lastMessagePreview, '');
      });

      test('defaults unReadCount to 0 when missing', () {
        final json = {
          'id': 'conv-2',
          'participant': {'id': 'user-2', 'display_name': 'Alice'},
          'last_message': tLastMessage,
        };
        expect(ConversationModel.fromJson(json).unReadCount, 0);
      });

      test('defaults participantName to Unknown when display_name missing', () {
        final model = ConversationModel.fromJson(
          _buildJson(participant: {'id': 'user-2'}, lastMessage: tLastMessage),
        );
        expect(model.participantName, 'Unknown');
      });

      test('defaults participantId to empty string when id missing', () {
        final model = ConversationModel.fromJson(
          _buildJson(
            participant: {'display_name': 'Alice'},
            lastMessage: tLastMessage,
          ),
        );
        expect(model.participantId, '');
      });

      test('handles missing last_message gracefully', () {
        final json = {
          'id': 'conv-1',
          'participant': {'id': 'user-2', 'display_name': 'Alice'},
          'unread_count': 0,
        };
        final model = ConversationModel.fromJson(json);
        expect(model.lastMessagePreview, '');
        expect(model.lastMessageDate, isNotNull);
      });

      test('handles null participant gracefully', () {
        final json = {
          'id': 'conv-1',
          'last_message': tLastMessage,
          'unread_count': 1,
        };
        final model = ConversationModel.fromJson(json);
        expect(model.participantId, '');
        expect(model.participantName, 'Unknown');
      });

      test('uses DateTime.now() when last_message created_at is null', () {
        final before = DateTime.now();
        final model = ConversationModel.fromJson(
          _buildJson(lastMessage: {'body': 'Hi'}),
        );
        final after = DateTime.now();
        expect(
          model.lastMessageDate.millisecondsSinceEpoch,
          greaterThanOrEqualTo(before.millisecondsSinceEpoch),
        );
        expect(
          model.lastMessageDate.millisecondsSinceEpoch,
          lessThanOrEqualTo(after.millisecondsSinceEpoch),
        );
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final model = ConversationModel(
          conversationId: 'conv-1',
          participantId: 'user-2',
          participantName: 'Alice',
          participantAvatar: 'https://example.com/avatar.png',
          lastMessagePreview: 'Hey there',
          lastMessageDate: tDate,
          unReadCount: 2,
        );
        final json = model.toJson();
        expect(json['id'], 'conv-1');
        expect(json['unread_count'], 2);
        final participant = json['participant'] as Map<String, dynamic>;
        expect(participant['id'], 'user-2');
        expect(participant['display_name'], 'Alice');
        expect(
          participant['profile_picture'],
          'https://example.com/avatar.png',
        );
        final lastMsg = json['last_message'] as Map<String, dynamic>?;
        expect(lastMsg, isNotNull);
        expect(lastMsg!['body'], 'Hey there');
        expect(lastMsg['created_at'], tDate.toIso8601String());
      });

      test('sets last_message to null when lastMessagePreview is empty', () {
        final model = ConversationModel(
          conversationId: 'conv-2',
          participantId: 'user-3',
          participantName: 'Bob',
          lastMessagePreview: '',
          lastMessageDate: tDate,
          unReadCount: 0,
        );
        final json = model.toJson();
        expect(json['last_message'], isNull);
      });
    });

    test('is a subtype of Conversation', () {
      final model = ConversationModel(
        conversationId: 'conv-1',
        participantId: 'user-2',
        participantName: 'Alice',
        lastMessagePreview: 'Hi',
        lastMessageDate: tDate,
        unReadCount: 0,
      );
      expect(model, isA<Conversation>());
    });
  });
}
