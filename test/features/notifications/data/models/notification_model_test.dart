import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/notifications/data/models/notification_model.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

Map<String, dynamic> _buildJson({
  String id = 'notif-1',
  String type = 'follow',
  Map<String, dynamic>? actor,
  String? resourceType,
  String? resourceId,
  Map<String, dynamic>? resourceDetails,
  bool? isRead = false,
  String createdAt = '2024-01-15T10:30:00.000Z',
  String? actionUserId,
}) {
  return {
    'id': id,
    'type': type,
    'actor': ?actor,
    'resource_type': ?resourceType,
    'resource_id': ?resourceId,
    'resource_details': ?resourceDetails,
    'is_read': ?isRead,
    'created_at': createdAt,
    'action_user_id': ?actionUserId,
  };
}

void main() {
  group('NotificationModel.fromJson', () {
    group('notification types', () {
      test('maps "follow" type correctly', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            type: 'follow',
            actor: {'id': 'u1', 'display_name': 'Alice'},
          ),
        );
        expect(model.type, NotificationType.follow);
      });

      test('maps "like" type correctly', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            type: 'like',
            actor: {'id': 'u1', 'display_name': 'Alice'},
          ),
        );
        expect(model.type, NotificationType.like);
      });

      test('maps "repost" type correctly', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            type: 'repost',
            actor: {'id': 'u1', 'display_name': 'Alice'},
          ),
        );
        expect(model.type, NotificationType.repost);
      });

      test('maps "comment" type correctly', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            type: 'comment',
            actor: {'id': 'u1', 'display_name': 'Alice'},
          ),
        );
        expect(model.type, NotificationType.comment);
      });

      test('maps "new_post_by_followed" type correctly', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            type: 'new_post_by_followed',
            actor: {'id': 'u1', 'display_name': 'Alice'},
          ),
        );
        expect(model.type, NotificationType.newPostByFollowed);
      });

      test('unknown type defaults to newPostByFollowed', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            type: 'some_unknown_event',
            actor: {'id': 'u1', 'display_name': 'Alice'},
          ),
        );
        expect(model.type, NotificationType.newPostByFollowed);
      });
    });

    group('resource types', () {
      test('maps "track" resource type', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceType: 'track',
          ),
        );
        expect(model.resourceType, ResourceType.track);
      });

      test('maps "playlist" resource type', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceType: 'playlist',
          ),
        );
        expect(model.resourceType, ResourceType.playlist);
      });

      test('maps "comment" resource type', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceType: 'comment',
          ),
        );
        expect(model.resourceType, ResourceType.comment);
      });

      test('null resource_type maps to null', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'display_name': 'Alice'}),
        );
        expect(model.resourceType, isNull);
      });

      test('unknown resource type maps to null', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceType: 'unknown_resource',
          ),
        );
        expect(model.resourceType, isNull);
      });
    });

    group('actor fields', () {
      test('reads actorId from actor.id', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'actor-123', 'display_name': 'Bob'}),
        );
        expect(model.actorId, 'actor-123');
      });

      test('falls back to action_user_id when actor.id is null', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'display_name': 'Bob'},
            actionUserId: 'action-456',
          ),
        );
        expect(model.actorId, 'action-456');
      });

      test(
        'actorId defaults to empty string when both id and action_user_id are absent',
        () {
          final model = NotificationModel.fromJson(_buildJson(actor: {}));
          expect(model.actorId, '');
        },
      );

      test('uses actor.display_name for actorDisplayName', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'display_name': 'Alice Smith'}),
        );
        expect(model.actorDisplayName, 'Alice Smith');
      });

      test('falls back to actor.username when display_name is null', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'username': 'alicesmith'}),
        );
        expect(model.actorDisplayName, 'alicesmith');
      });

      test(
        'actorDisplayName defaults to "Unknown" when both display_name and username are absent',
        () {
          final model = NotificationModel.fromJson(
            _buildJson(actor: {'id': 'u1'}),
          );
          expect(model.actorDisplayName, 'Unknown');
        },
      );

      test('reads actorUsername from actor.username', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'username': 'alice', 'display_name': 'Alice'},
          ),
        );
        expect(model.actorUsername, 'alice');
      });

      test('actorUsername is null when absent', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'display_name': 'Alice'}),
        );
        expect(model.actorUsername, isNull);
      });

      test('reads actorAvatar from actor.avatar', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {
              'id': 'u1',
              'display_name': 'Alice',
              'avatar': 'https://img.png',
            },
          ),
        );
        expect(model.actorAvatar, 'https://img.png');
      });

      test('actorAvatar is null when absent', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'display_name': 'Alice'}),
        );
        expect(model.actorAvatar, isNull);
      });

      test('handles missing actor key by using action_user_id', () {
        final json = {
          'id': 'n1',
          'type': 'follow',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
          'action_user_id': 'u99',
        };
        final model = NotificationModel.fromJson(json);
        expect(model.actorId, 'u99');
        expect(model.actorDisplayName, 'Unknown');
      });
    });

    group('resource_details fields', () {
      test('reads resourceTitle from resource_details.title', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceDetails: {'title': 'My Track'},
          ),
        );
        expect(model.resourceTitle, 'My Track');
      });

      test('reads resourceContent from resource_details.content', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceDetails: {'content': 'Nice comment'},
          ),
        );
        expect(model.resourceContent, 'Nice comment');
      });

      test('uses cover_image for resourceImageUrl (track)', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceDetails: {'cover_image': 'https://track-cover.jpg'},
          ),
        );
        expect(model.resourceImageUrl, 'https://track-cover.jpg');
      });

      test('falls back to cover_url when cover_image is null (playlist)', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceDetails: {'cover_url': 'https://playlist-cover.jpg'},
          ),
        );
        expect(model.resourceImageUrl, 'https://playlist-cover.jpg');
      });

      test('resourceImageUrl is null when both cover fields are absent', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceDetails: {},
          ),
        );
        expect(model.resourceImageUrl, isNull);
      });

      test('null resource_details leaves all resource fields null', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'display_name': 'Alice'}),
        );
        expect(model.resourceTitle, isNull);
        expect(model.resourceContent, isNull);
        expect(model.resourceImageUrl, isNull);
      });
    });

    group('other top-level fields', () {
      test('reads is_read correctly when true', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            isRead: true,
          ),
        );
        expect(model.isRead, true);
      });

      test('is_read defaults to false when key is absent', () {
        final json = {
          'id': 'n1',
          'type': 'follow',
          'actor': {'id': 'u1', 'display_name': 'Alice'},
          'created_at': '2024-01-15T10:30:00.000Z',
        };
        final model = NotificationModel.fromJson(json);
        expect(model.isRead, false);
      });

      test('parses createdAt from ISO 8601 string', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            createdAt: '2024-03-20T08:00:00.000Z',
          ),
        );
        expect(model.createdAt, DateTime.parse('2024-03-20T08:00:00.000Z'));
      });

      test('reads resource_id from top-level field', () {
        final model = NotificationModel.fromJson(
          _buildJson(
            actor: {'id': 'u1', 'display_name': 'Alice'},
            resourceId: 'track-abc',
          ),
        );
        expect(model.resourceId, 'track-abc');
      });

      test('resourceId is null when absent', () {
        final model = NotificationModel.fromJson(
          _buildJson(actor: {'id': 'u1', 'display_name': 'Alice'}),
        );
        expect(model.resourceId, isNull);
      });
    });

    test('is a NotificationEntity subtype', () {
      final model = NotificationModel.fromJson(
        _buildJson(actor: {'id': 'u1', 'display_name': 'Alice'}),
      );
      expect(model, isA<NotificationEntity>());
    });
  });
}
