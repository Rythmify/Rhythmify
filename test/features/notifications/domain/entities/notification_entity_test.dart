import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 15);

  final tEntity = NotificationEntity(
    id: 'n1',
    type: NotificationType.follow,
    actorId: 'u1',
    actorDisplayName: 'Alice',
    isRead: false,
    createdAt: tCreatedAt,
  );

  group('NotificationEntity', () {
    group('default values', () {
      test('isActorFollowed defaults to false', () {
        expect(tEntity.isActorFollowed, false);
      });

      test('optional fields default to null', () {
        expect(tEntity.actorUsername, isNull);
        expect(tEntity.actorAvatar, isNull);
        expect(tEntity.resourceType, isNull);
        expect(tEntity.resourceId, isNull);
        expect(tEntity.resourceTitle, isNull);
        expect(tEntity.resourceContent, isNull);
        expect(tEntity.resourceImageUrl, isNull);
      });
    });

    group('copyWith', () {
      test('copies with new isRead value', () {
        final copy = tEntity.copyWith(isRead: true);
        expect(copy.isRead, true);
        expect(copy.id, tEntity.id);
        expect(copy.actorDisplayName, tEntity.actorDisplayName);
        expect(copy.type, tEntity.type);
      });

      test('copies with new isActorFollowed value', () {
        final copy = tEntity.copyWith(isActorFollowed: true);
        expect(copy.isActorFollowed, true);
        expect(copy.isRead, tEntity.isRead);
      });

      test('copyWith without args preserves all fields', () {
        final copy = tEntity.copyWith();
        expect(copy.isRead, tEntity.isRead);
        expect(copy.isActorFollowed, tEntity.isActorFollowed);
        expect(copy.id, tEntity.id);
      });

      test('copyWith preserves optional fields', () {
        final full = NotificationEntity(
          id: 'n1',
          type: NotificationType.comment,
          actorId: 'u1',
          actorUsername: 'alice',
          actorDisplayName: 'Alice',
          actorAvatar: 'https://img.png',
          resourceType: ResourceType.track,
          resourceId: 'track-1',
          resourceTitle: 'My Song',
          resourceContent: 'A comment',
          resourceImageUrl: 'https://cover.jpg',
          isRead: false,
          isActorFollowed: false,
          createdAt: tCreatedAt,
        );
        final copy = full.copyWith(isRead: true);
        expect(copy.actorUsername, 'alice');
        expect(copy.resourceType, ResourceType.track);
        expect(copy.resourceTitle, 'My Song');
        expect(copy.isRead, true);
      });
    });

    group('Equatable props', () {
      test('two entities with same data are equal', () {
        final a = NotificationEntity(
          id: 'n1',
          type: NotificationType.like,
          actorId: 'u1',
          actorDisplayName: 'Alice',
          isRead: false,
          createdAt: tCreatedAt,
        );
        final b = NotificationEntity(
          id: 'n1',
          type: NotificationType.like,
          actorId: 'u1',
          actorDisplayName: 'Alice',
          isRead: false,
          createdAt: tCreatedAt,
        );
        expect(a, equals(b));
      });

      test('entities with different ids are not equal', () {
        final a = tEntity;
        final b = NotificationEntity(
          id: 'n2',
          type: tEntity.type,
          actorId: tEntity.actorId,
          actorDisplayName: tEntity.actorDisplayName,
          isRead: tEntity.isRead,
          createdAt: tEntity.createdAt,
        );
        expect(a, isNot(equals(b)));
      });

      test('entities with different types are not equal', () {
        final a = tEntity;
        final b = NotificationEntity(
          id: tEntity.id,
          type: NotificationType.like,
          actorId: tEntity.actorId,
          actorDisplayName: tEntity.actorDisplayName,
          isRead: tEntity.isRead,
          createdAt: tEntity.createdAt,
        );
        expect(a, isNot(equals(b)));
      });

      test('entities with different isRead are not equal', () {
        final a = tEntity;
        final b = tEntity.copyWith(isRead: true);
        expect(a, isNot(equals(b)));
      });

      test('props list has 14 elements', () {
        expect(tEntity.props.length, 14);
      });
    });
  });
}
