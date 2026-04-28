import '../../domain/entities/notification_preferences_entity.dart';

MessagesFrom _messagesFromString(String? value) {
  switch (value) {
    case 'followers_only':
      return MessagesFrom.followersOnly;
    case 'nobody':
      return MessagesFrom.nobody;
    default:
      return MessagesFrom.everyone;
  }
}

String _messagesFromToString(MessagesFrom value) {
  switch (value) {
    case MessagesFrom.followersOnly:
      return 'followers_only';
    case MessagesFrom.nobody:
      return 'nobody';
    case MessagesFrom.everyone:
      return 'everyone';
  }
}

class NotificationPreferencesModel extends NotificationPreferencesEntity {
  const NotificationPreferencesModel({
    required super.newFollowerPush,
    required super.newFollowerEmail,
    required super.repostOfYourPostPush,
    required super.repostOfYourPostEmail,
    required super.newPostByFollowedPush,
    required super.newPostByFollowedEmail,
    required super.likesAndPlaysPush,
    required super.likesAndPlaysEmail,
    required super.commentOnPostPush,
    required super.commentOnPostEmail,
    required super.recommendedContentPush,
    required super.recommendedContentEmail,
    required super.newMessagePush,
    required super.newMessageEmail,
    required super.messagesFrom,
    required super.featureUpdatesPush,
    required super.featureUpdatesEmail,
    required super.surveysAndFeedbackPush,
    required super.surveysAndFeedbackEmail,
    required super.promotionalContentPush,
    required super.promotionalContentEmail,
    required super.newsletterEmail,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      newFollowerPush: json['new_follower_push'] as bool? ?? true,
      newFollowerEmail: json['new_follower_email'] as bool? ?? true,
      repostOfYourPostPush: json['repost_of_your_post_push'] as bool? ?? true,
      repostOfYourPostEmail: json['repost_of_your_post_email'] as bool? ?? true,
      newPostByFollowedPush: json['new_post_by_followed_push'] as bool? ?? true,
      newPostByFollowedEmail:
          json['new_post_by_followed_email'] as bool? ?? true,
      likesAndPlaysPush: json['likes_and_plays_push'] as bool? ?? true,
      likesAndPlaysEmail: json['likes_and_plays_email'] as bool? ?? true,
      commentOnPostPush: json['comment_on_post_push'] as bool? ?? true,
      commentOnPostEmail: json['comment_on_post_email'] as bool? ?? true,
      recommendedContentPush: json['recommended_content_push'] as bool? ?? true,
      recommendedContentEmail:
          json['recommended_content_email'] as bool? ?? true,
      newMessagePush: json['new_message_push'] as bool? ?? true,
      newMessageEmail: json['new_message_email'] as bool? ?? true,
      messagesFrom: _messagesFromString(json['messages_from'] as String?),
      featureUpdatesPush: json['feature_updates_push'] as bool? ?? true,
      featureUpdatesEmail: json['feature_updates_email'] as bool? ?? true,
      surveysAndFeedbackPush:
          json['surveys_and_feedback_push'] as bool? ?? true,
      surveysAndFeedbackEmail:
          json['surveys_and_feedback_email'] as bool? ?? true,
      promotionalContentPush: json['promotional_content_push'] as bool? ?? true,
      promotionalContentEmail:
          json['promotional_content_email'] as bool? ?? true,
      newsletterEmail: json['newsletter_email'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_follower_push': newFollowerPush,
      'new_follower_email': newFollowerEmail,
      'repost_of_your_post_push': repostOfYourPostPush,
      'repost_of_your_post_email': repostOfYourPostEmail,
      'new_post_by_followed_push': newPostByFollowedPush,
      'new_post_by_followed_email': newPostByFollowedEmail,
      'likes_and_plays_push': likesAndPlaysPush,
      'likes_and_plays_email': likesAndPlaysEmail,
      'comment_on_post_push': commentOnPostPush,
      'comment_on_post_email': commentOnPostEmail,
      'recommended_content_push': recommendedContentPush,
      'recommended_content_email': recommendedContentEmail,
      'new_message_push': newMessagePush,
      'new_message_email': newMessageEmail,
      'messages_from': _messagesFromToString(messagesFrom),
      'feature_updates_push': featureUpdatesPush,
      'feature_updates_email': featureUpdatesEmail,
      'surveys_and_feedback_push': surveysAndFeedbackPush,
      'surveys_and_feedback_email': surveysAndFeedbackEmail,
      'promotional_content_push': promotionalContentPush,
      'promotional_content_email': promotionalContentEmail,
      'newsletter_email': newsletterEmail,
    };
  }

  factory NotificationPreferencesModel.fromEntity(
    NotificationPreferencesEntity entity,
  ) {
    return NotificationPreferencesModel(
      newFollowerPush: entity.newFollowerPush,
      newFollowerEmail: entity.newFollowerEmail,
      repostOfYourPostPush: entity.repostOfYourPostPush,
      repostOfYourPostEmail: entity.repostOfYourPostEmail,
      newPostByFollowedPush: entity.newPostByFollowedPush,
      newPostByFollowedEmail: entity.newPostByFollowedEmail,
      likesAndPlaysPush: entity.likesAndPlaysPush,
      likesAndPlaysEmail: entity.likesAndPlaysEmail,
      commentOnPostPush: entity.commentOnPostPush,
      commentOnPostEmail: entity.commentOnPostEmail,
      recommendedContentPush: entity.recommendedContentPush,
      recommendedContentEmail: entity.recommendedContentEmail,
      newMessagePush: entity.newMessagePush,
      newMessageEmail: entity.newMessageEmail,
      messagesFrom: entity.messagesFrom,
      featureUpdatesPush: entity.featureUpdatesPush,
      featureUpdatesEmail: entity.featureUpdatesEmail,
      surveysAndFeedbackPush: entity.surveysAndFeedbackPush,
      surveysAndFeedbackEmail: entity.surveysAndFeedbackEmail,
      promotionalContentPush: entity.promotionalContentPush,
      promotionalContentEmail: entity.promotionalContentEmail,
      newsletterEmail: entity.newsletterEmail,
    );
  }

  NotificationPreferencesEntity toDomain() => NotificationPreferencesEntity(
    newFollowerPush: newFollowerPush,
    newFollowerEmail: newFollowerEmail,
    repostOfYourPostPush: repostOfYourPostPush,
    repostOfYourPostEmail: repostOfYourPostEmail,
    newPostByFollowedPush: newPostByFollowedPush,
    newPostByFollowedEmail: newPostByFollowedEmail,
    likesAndPlaysPush: likesAndPlaysPush,
    likesAndPlaysEmail: likesAndPlaysEmail,
    commentOnPostPush: commentOnPostPush,
    commentOnPostEmail: commentOnPostEmail,
    recommendedContentPush: recommendedContentPush,
    recommendedContentEmail: recommendedContentEmail,
    newMessagePush: newMessagePush,
    newMessageEmail: newMessageEmail,
    messagesFrom: messagesFrom,
    featureUpdatesPush: featureUpdatesPush,
    featureUpdatesEmail: featureUpdatesEmail,
    surveysAndFeedbackPush: surveysAndFeedbackPush,
    surveysAndFeedbackEmail: surveysAndFeedbackEmail,
    promotionalContentPush: promotionalContentPush,
    promotionalContentEmail: promotionalContentEmail,
    newsletterEmail: newsletterEmail,
  );
}
