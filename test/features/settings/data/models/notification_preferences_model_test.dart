import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';

/// Full JSON payload with all fields explicitly set (push=false, email=true)
/// and `messages_from` as `followers_only`. Used for [fromJson] round-trip tests.
const tFullJson = <String, dynamic>{
  'new_follower_push': false,
  'new_follower_email': true,
  'repost_of_your_post_push': false,
  'repost_of_your_post_email': true,
  'new_post_by_followed_push': false,
  'new_post_by_followed_email': true,
  'likes_and_plays_push': false,
  'likes_and_plays_email': true,
  'comment_on_post_push': false,
  'comment_on_post_email': true,
  'recommended_content_push': false,
  'recommended_content_email': true,
  'new_message_push': false,
  'new_message_email': true,
  'messages_from': 'followers_only',
  'feature_updates_push': false,
  'feature_updates_email': true,
  'surveys_and_feedback_push': false,
  'surveys_and_feedback_email': true,
  'promotional_content_push': false,
  'promotional_content_email': true,
  'newsletter_email': false,
};

/// Domain entity equivalent of [tFullJson] — used to verify [fromEntity] and [toDomain].
const tEntity = NotificationPreferencesEntity(
  newFollowerPush: false,
  newFollowerEmail: true,
  repostOfYourPostPush: false,
  repostOfYourPostEmail: true,
  newPostByFollowedPush: false,
  newPostByFollowedEmail: true,
  likesAndPlaysPush: false,
  likesAndPlaysEmail: true,
  commentOnPostPush: false,
  commentOnPostEmail: true,
  recommendedContentPush: false,
  recommendedContentEmail: true,
  newMessagePush: false,
  newMessageEmail: true,
  messagesFrom: MessagesFrom.followersOnly,
  featureUpdatesPush: false,
  featureUpdatesEmail: true,
  surveysAndFeedbackPush: false,
  surveysAndFeedbackEmail: true,
  promotionalContentPush: false,
  promotionalContentEmail: true,
  newsletterEmail: false,
);

/// Tests for [NotificationPreferencesModel].
///
/// Covers [fromJson] mapping all 22 fields from snake_case keys, the
/// [MessagesFrom] enum conversion in both directions, [toJson] key names,
/// [fromEntity] copying from a domain entity, [toDomain] producing an equal
/// entity, and the all-true default behaviour when JSON fields are absent.
void main() {
  group('NotificationPreferencesModel', () {
    group('fromJson', () {
      test('maps all fields from snake_case JSON', () {
        final model = NotificationPreferencesModel.fromJson(tFullJson);

        expect(model.newFollowerPush, false);
        expect(model.newFollowerEmail, true);
        expect(model.repostOfYourPostPush, false);
        expect(model.repostOfYourPostEmail, true);
        expect(model.newPostByFollowedPush, false);
        expect(model.newPostByFollowedEmail, true);
        expect(model.likesAndPlaysPush, false);
        expect(model.likesAndPlaysEmail, true);
        expect(model.commentOnPostPush, false);
        expect(model.commentOnPostEmail, true);
        expect(model.recommendedContentPush, false);
        expect(model.recommendedContentEmail, true);
        expect(model.newMessagePush, false);
        expect(model.newMessageEmail, true);
        expect(model.messagesFrom, MessagesFrom.followersOnly);
        expect(model.featureUpdatesPush, false);
        expect(model.featureUpdatesEmail, true);
        expect(model.surveysAndFeedbackPush, false);
        expect(model.surveysAndFeedbackEmail, true);
        expect(model.promotionalContentPush, false);
        expect(model.promotionalContentEmail, true);
        expect(model.newsletterEmail, false);
      });

      test('defaults all bool fields to true when keys are absent', () {
        final model = NotificationPreferencesModel.fromJson({});

        expect(model.newFollowerPush, true);
        expect(model.newFollowerEmail, true);
        expect(model.repostOfYourPostPush, true);
        expect(model.repostOfYourPostEmail, true);
        expect(model.newPostByFollowedPush, true);
        expect(model.newPostByFollowedEmail, true);
        expect(model.likesAndPlaysPush, true);
        expect(model.likesAndPlaysEmail, true);
        expect(model.commentOnPostPush, true);
        expect(model.commentOnPostEmail, true);
        expect(model.recommendedContentPush, true);
        expect(model.recommendedContentEmail, true);
        expect(model.newMessagePush, true);
        expect(model.newMessageEmail, true);
        expect(model.featureUpdatesPush, true);
        expect(model.featureUpdatesEmail, true);
        expect(model.surveysAndFeedbackPush, true);
        expect(model.surveysAndFeedbackEmail, true);
        expect(model.promotionalContentPush, true);
        expect(model.promotionalContentEmail, true);
        expect(model.newsletterEmail, true);
      });

      test('defaults messagesFrom to everyone when key is absent', () {
        final model = NotificationPreferencesModel.fromJson({});
        expect(model.messagesFrom, MessagesFrom.everyone);
      });

      test('parses messages_from = everyone', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'everyone',
        });
        expect(model.messagesFrom, MessagesFrom.everyone);
      });

      test('parses messages_from = followers_only', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'followers_only',
        });
        expect(model.messagesFrom, MessagesFrom.followersOnly);
      });

      test('parses messages_from = nobody', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'nobody',
        });
        expect(model.messagesFrom, MessagesFrom.nobody);
      });

      test('defaults to everyone for an unrecognised messages_from string', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'some_unknown_value',
        });
        expect(model.messagesFrom, MessagesFrom.everyone);
      });

      test('defaults to everyone when messages_from is null', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': null,
        });
        expect(model.messagesFrom, MessagesFrom.everyone);
      });
    });

    group('toJson', () {
      test('serialises all 22 fields to snake_case keys', () {
        final model = NotificationPreferencesModel.fromJson(tFullJson);
        final json = model.toJson();

        expect(json['new_follower_push'], false);
        expect(json['new_follower_email'], true);
        expect(json['repost_of_your_post_push'], false);
        expect(json['repost_of_your_post_email'], true);
        expect(json['new_post_by_followed_push'], false);
        expect(json['new_post_by_followed_email'], true);
        expect(json['likes_and_plays_push'], false);
        expect(json['likes_and_plays_email'], true);
        expect(json['comment_on_post_push'], false);
        expect(json['comment_on_post_email'], true);
        expect(json['recommended_content_push'], false);
        expect(json['recommended_content_email'], true);
        expect(json['new_message_push'], false);
        expect(json['new_message_email'], true);
        expect(json['messages_from'], 'followers_only');
        expect(json['feature_updates_push'], false);
        expect(json['feature_updates_email'], true);
        expect(json['surveys_and_feedback_push'], false);
        expect(json['surveys_and_feedback_email'], true);
        expect(json['promotional_content_push'], false);
        expect(json['promotional_content_email'], true);
        expect(json['newsletter_email'], false);
        expect(json.length, 22);
      });

      test('serialises messages_from = everyone', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'everyone',
        });
        expect(model.toJson()['messages_from'], 'everyone');
      });

      test('serialises messages_from = followers_only', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'followers_only',
        });
        expect(model.toJson()['messages_from'], 'followers_only');
      });

      test('serialises messages_from = nobody', () {
        final model = NotificationPreferencesModel.fromJson({
          'messages_from': 'nobody',
        });
        expect(model.toJson()['messages_from'], 'nobody');
      });
    });

    group('fromEntity', () {
      test('creates model that equals the source entity', () {
        final model = NotificationPreferencesModel.fromEntity(tEntity);

        expect(model.newFollowerPush, tEntity.newFollowerPush);
        expect(model.newFollowerEmail, tEntity.newFollowerEmail);
        expect(model.repostOfYourPostPush, tEntity.repostOfYourPostPush);
        expect(model.repostOfYourPostEmail, tEntity.repostOfYourPostEmail);
        expect(model.newPostByFollowedPush, tEntity.newPostByFollowedPush);
        expect(model.newPostByFollowedEmail, tEntity.newPostByFollowedEmail);
        expect(model.likesAndPlaysPush, tEntity.likesAndPlaysPush);
        expect(model.likesAndPlaysEmail, tEntity.likesAndPlaysEmail);
        expect(model.commentOnPostPush, tEntity.commentOnPostPush);
        expect(model.commentOnPostEmail, tEntity.commentOnPostEmail);
        expect(model.recommendedContentPush, tEntity.recommendedContentPush);
        expect(model.recommendedContentEmail, tEntity.recommendedContentEmail);
        expect(model.newMessagePush, tEntity.newMessagePush);
        expect(model.newMessageEmail, tEntity.newMessageEmail);
        expect(model.messagesFrom, tEntity.messagesFrom);
        expect(model.featureUpdatesPush, tEntity.featureUpdatesPush);
        expect(model.featureUpdatesEmail, tEntity.featureUpdatesEmail);
        expect(model.surveysAndFeedbackPush, tEntity.surveysAndFeedbackPush);
        expect(model.surveysAndFeedbackEmail, tEntity.surveysAndFeedbackEmail);
        expect(model.promotionalContentPush, tEntity.promotionalContentPush);
        expect(model.promotionalContentEmail, tEntity.promotionalContentEmail);
        expect(model.newsletterEmail, tEntity.newsletterEmail);
      });
    });

    group('toDomain', () {
      test('returns a NotificationPreferencesEntity with identical values', () {
        final model = NotificationPreferencesModel.fromJson(tFullJson);
        final entity = model.toDomain();

        expect(entity, isA<NotificationPreferencesEntity>());
        expect(entity.newFollowerPush, model.newFollowerPush);
        expect(entity.newFollowerEmail, model.newFollowerEmail);
        expect(entity.repostOfYourPostPush, model.repostOfYourPostPush);
        expect(entity.repostOfYourPostEmail, model.repostOfYourPostEmail);
        expect(entity.newPostByFollowedPush, model.newPostByFollowedPush);
        expect(entity.newPostByFollowedEmail, model.newPostByFollowedEmail);
        expect(entity.likesAndPlaysPush, model.likesAndPlaysPush);
        expect(entity.likesAndPlaysEmail, model.likesAndPlaysEmail);
        expect(entity.commentOnPostPush, model.commentOnPostPush);
        expect(entity.commentOnPostEmail, model.commentOnPostEmail);
        expect(entity.recommendedContentPush, model.recommendedContentPush);
        expect(entity.recommendedContentEmail, model.recommendedContentEmail);
        expect(entity.newMessagePush, model.newMessagePush);
        expect(entity.newMessageEmail, model.newMessageEmail);
        expect(entity.messagesFrom, model.messagesFrom);
        expect(entity.featureUpdatesPush, model.featureUpdatesPush);
        expect(entity.featureUpdatesEmail, model.featureUpdatesEmail);
        expect(entity.surveysAndFeedbackPush, model.surveysAndFeedbackPush);
        expect(entity.surveysAndFeedbackEmail, model.surveysAndFeedbackEmail);
        expect(entity.promotionalContentPush, model.promotionalContentPush);
        expect(entity.promotionalContentEmail, model.promotionalContentEmail);
        expect(entity.newsletterEmail, model.newsletterEmail);
      });

      test('round-trip fromEntity → toDomain preserves all values', () {
        final model = NotificationPreferencesModel.fromEntity(tEntity);
        final roundTripped = model.toDomain();
        expect(roundTripped, tEntity);
      });
    });
  });
}
