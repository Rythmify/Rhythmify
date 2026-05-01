import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';

const tEntity = NotificationPreferencesEntity(
  newFollowerPush: true,
  newFollowerEmail: false,
  repostOfYourPostPush: true,
  repostOfYourPostEmail: false,
  newPostByFollowedPush: true,
  newPostByFollowedEmail: false,
  likesAndPlaysPush: true,
  likesAndPlaysEmail: false,
  commentOnPostPush: true,
  commentOnPostEmail: false,
  recommendedContentPush: true,
  recommendedContentEmail: false,
  newMessagePush: true,
  newMessageEmail: false,
  messagesFrom: MessagesFrom.everyone,
  featureUpdatesPush: true,
  featureUpdatesEmail: false,
  surveysAndFeedbackPush: true,
  surveysAndFeedbackEmail: false,
  promotionalContentPush: true,
  promotionalContentEmail: false,
  newsletterEmail: true,
);

void main() {
  group('NotificationPreferencesEntity', () {
    test('supports value equality via Equatable', () {
      const same = NotificationPreferencesEntity(
        newFollowerPush: true,
        newFollowerEmail: false,
        repostOfYourPostPush: true,
        repostOfYourPostEmail: false,
        newPostByFollowedPush: true,
        newPostByFollowedEmail: false,
        likesAndPlaysPush: true,
        likesAndPlaysEmail: false,
        commentOnPostPush: true,
        commentOnPostEmail: false,
        recommendedContentPush: true,
        recommendedContentEmail: false,
        newMessagePush: true,
        newMessageEmail: false,
        messagesFrom: MessagesFrom.everyone,
        featureUpdatesPush: true,
        featureUpdatesEmail: false,
        surveysAndFeedbackPush: true,
        surveysAndFeedbackEmail: false,
        promotionalContentPush: true,
        promotionalContentEmail: false,
        newsletterEmail: true,
      );
      expect(tEntity, same);
    });

    test('is not equal when a field differs', () {
      final different = tEntity.copyWith(newFollowerPush: false);
      expect(tEntity, isNot(different));
    });

    test('props contains all 22 fields', () {
      expect(tEntity.props.length, 22);
    });

    group('copyWith', () {
      test('returns identical entity when no overrides given', () {
        expect(tEntity.copyWith(), tEntity);
      });

      test('overrides newFollowerPush only', () {
        final updated = tEntity.copyWith(newFollowerPush: false);
        expect(updated.newFollowerPush, false);
        expect(updated.newFollowerEmail, tEntity.newFollowerEmail);
      });

      test('overrides newFollowerEmail only', () {
        final updated = tEntity.copyWith(newFollowerEmail: true);
        expect(updated.newFollowerEmail, true);
      });

      test('overrides repostOfYourPostPush only', () {
        final updated = tEntity.copyWith(repostOfYourPostPush: false);
        expect(updated.repostOfYourPostPush, false);
      });

      test('overrides repostOfYourPostEmail only', () {
        final updated = tEntity.copyWith(repostOfYourPostEmail: true);
        expect(updated.repostOfYourPostEmail, true);
      });

      test('overrides newPostByFollowedPush only', () {
        final updated = tEntity.copyWith(newPostByFollowedPush: false);
        expect(updated.newPostByFollowedPush, false);
      });

      test('overrides newPostByFollowedEmail only', () {
        final updated = tEntity.copyWith(newPostByFollowedEmail: true);
        expect(updated.newPostByFollowedEmail, true);
      });

      test('overrides likesAndPlaysPush only', () {
        final updated = tEntity.copyWith(likesAndPlaysPush: false);
        expect(updated.likesAndPlaysPush, false);
      });

      test('overrides likesAndPlaysEmail only', () {
        final updated = tEntity.copyWith(likesAndPlaysEmail: true);
        expect(updated.likesAndPlaysEmail, true);
      });

      test('overrides commentOnPostPush only', () {
        final updated = tEntity.copyWith(commentOnPostPush: false);
        expect(updated.commentOnPostPush, false);
      });

      test('overrides commentOnPostEmail only', () {
        final updated = tEntity.copyWith(commentOnPostEmail: true);
        expect(updated.commentOnPostEmail, true);
      });

      test('overrides recommendedContentPush only', () {
        final updated = tEntity.copyWith(recommendedContentPush: false);
        expect(updated.recommendedContentPush, false);
      });

      test('overrides recommendedContentEmail only', () {
        final updated = tEntity.copyWith(recommendedContentEmail: true);
        expect(updated.recommendedContentEmail, true);
      });

      test('overrides newMessagePush only', () {
        final updated = tEntity.copyWith(newMessagePush: false);
        expect(updated.newMessagePush, false);
      });

      test('overrides newMessageEmail only', () {
        final updated = tEntity.copyWith(newMessageEmail: true);
        expect(updated.newMessageEmail, true);
      });

      test('overrides messagesFrom to followersOnly', () {
        final updated = tEntity.copyWith(messagesFrom: MessagesFrom.followersOnly);
        expect(updated.messagesFrom, MessagesFrom.followersOnly);
      });

      test('overrides messagesFrom to nobody', () {
        final updated = tEntity.copyWith(messagesFrom: MessagesFrom.nobody);
        expect(updated.messagesFrom, MessagesFrom.nobody);
      });

      test('overrides featureUpdatesPush only', () {
        final updated = tEntity.copyWith(featureUpdatesPush: false);
        expect(updated.featureUpdatesPush, false);
      });

      test('overrides featureUpdatesEmail only', () {
        final updated = tEntity.copyWith(featureUpdatesEmail: true);
        expect(updated.featureUpdatesEmail, true);
      });

      test('overrides surveysAndFeedbackPush only', () {
        final updated = tEntity.copyWith(surveysAndFeedbackPush: false);
        expect(updated.surveysAndFeedbackPush, false);
      });

      test('overrides surveysAndFeedbackEmail only', () {
        final updated = tEntity.copyWith(surveysAndFeedbackEmail: true);
        expect(updated.surveysAndFeedbackEmail, true);
      });

      test('overrides promotionalContentPush only', () {
        final updated = tEntity.copyWith(promotionalContentPush: false);
        expect(updated.promotionalContentPush, false);
      });

      test('overrides promotionalContentEmail only', () {
        final updated = tEntity.copyWith(promotionalContentEmail: true);
        expect(updated.promotionalContentEmail, true);
      });

      test('overrides newsletterEmail only', () {
        final updated = tEntity.copyWith(newsletterEmail: false);
        expect(updated.newsletterEmail, false);
      });

      test('overrides multiple fields at once', () {
        final updated = tEntity.copyWith(
          newFollowerPush: false,
          newsletterEmail: false,
          messagesFrom: MessagesFrom.nobody,
        );
        expect(updated.newFollowerPush, false);
        expect(updated.newsletterEmail, false);
        expect(updated.messagesFrom, MessagesFrom.nobody);
        expect(updated.newFollowerEmail, tEntity.newFollowerEmail);
        expect(updated.recommendedContentPush, tEntity.recommendedContentPush);
      });
    });

    group('MessagesFrom enum', () {
      test('has exactly three values', () {
        expect(MessagesFrom.values.length, 3);
      });

      test('contains everyone, followersOnly and nobody', () {
        expect(MessagesFrom.values, containsAll([
          MessagesFrom.everyone,
          MessagesFrom.followersOnly,
          MessagesFrom.nobody,
        ]));
      });
    });
  });
}
