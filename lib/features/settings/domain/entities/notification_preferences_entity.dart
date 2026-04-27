import 'package:equatable/equatable.dart';

enum MessagesFrom { everyone, followersOnly, nobody }

class NotificationPreferencesEntity extends Equatable {
  final bool newFollowerPush;
  final bool newFollowerEmail;
  final bool repostOfYourPostPush;
  final bool repostOfYourPostEmail;
  final bool newPostByFollowedPush;
  final bool newPostByFollowedEmail;
  final bool likesAndPlaysPush;
  final bool likesAndPlaysEmail;
  final bool commentOnPostPush;
  final bool commentOnPostEmail;
  final bool recommendedContentPush;
  final bool recommendedContentEmail;
  final bool newMessagePush;
  final bool newMessageEmail;
  final MessagesFrom messagesFrom;
  final bool featureUpdatesPush;
  final bool featureUpdatesEmail;
  final bool surveysAndFeedbackPush;
  final bool surveysAndFeedbackEmail;
  final bool promotionalContentPush;
  final bool promotionalContentEmail;
  final bool newsletterEmail;

  const NotificationPreferencesEntity({
    required this.newFollowerPush,
    required this.newFollowerEmail,
    required this.repostOfYourPostPush,
    required this.repostOfYourPostEmail,
    required this.newPostByFollowedPush,
    required this.newPostByFollowedEmail,
    required this.likesAndPlaysPush,
    required this.likesAndPlaysEmail,
    required this.commentOnPostPush,
    required this.commentOnPostEmail,
    required this.recommendedContentPush,
    required this.recommendedContentEmail,
    required this.newMessagePush,
    required this.newMessageEmail,
    required this.messagesFrom,
    required this.featureUpdatesPush,
    required this.featureUpdatesEmail,
    required this.surveysAndFeedbackPush,
    required this.surveysAndFeedbackEmail,
    required this.promotionalContentPush,
    required this.promotionalContentEmail,
    required this.newsletterEmail,
  });

  NotificationPreferencesEntity copyWith({
    bool? newFollowerPush,
    bool? newFollowerEmail,
    bool? repostOfYourPostPush,
    bool? repostOfYourPostEmail,
    bool? newPostByFollowedPush,
    bool? newPostByFollowedEmail,
    bool? likesAndPlaysPush,
    bool? likesAndPlaysEmail,
    bool? commentOnPostPush,
    bool? commentOnPostEmail,
    bool? recommendedContentPush,
    bool? recommendedContentEmail,
    bool? newMessagePush,
    bool? newMessageEmail,
    MessagesFrom? messagesFrom,
    bool? featureUpdatesPush,
    bool? featureUpdatesEmail,
    bool? surveysAndFeedbackPush,
    bool? surveysAndFeedbackEmail,
    bool? promotionalContentPush,
    bool? promotionalContentEmail,
    bool? newsletterEmail,
  }) {
    return NotificationPreferencesEntity(
      newFollowerPush: newFollowerPush ?? this.newFollowerPush,
      newFollowerEmail: newFollowerEmail ?? this.newFollowerEmail,
      repostOfYourPostPush: repostOfYourPostPush ?? this.repostOfYourPostPush,
      repostOfYourPostEmail:
          repostOfYourPostEmail ?? this.repostOfYourPostEmail,
      newPostByFollowedPush:
          newPostByFollowedPush ?? this.newPostByFollowedPush,
      newPostByFollowedEmail:
          newPostByFollowedEmail ?? this.newPostByFollowedEmail,
      likesAndPlaysPush: likesAndPlaysPush ?? this.likesAndPlaysPush,
      likesAndPlaysEmail: likesAndPlaysEmail ?? this.likesAndPlaysEmail,
      commentOnPostPush: commentOnPostPush ?? this.commentOnPostPush,
      commentOnPostEmail: commentOnPostEmail ?? this.commentOnPostEmail,
      recommendedContentPush:
          recommendedContentPush ?? this.recommendedContentPush,
      recommendedContentEmail:
          recommendedContentEmail ?? this.recommendedContentEmail,
      newMessagePush: newMessagePush ?? this.newMessagePush,
      newMessageEmail: newMessageEmail ?? this.newMessageEmail,
      messagesFrom: messagesFrom ?? this.messagesFrom,
      featureUpdatesPush: featureUpdatesPush ?? this.featureUpdatesPush,
      featureUpdatesEmail: featureUpdatesEmail ?? this.featureUpdatesEmail,
      surveysAndFeedbackPush:
          surveysAndFeedbackPush ?? this.surveysAndFeedbackPush,
      surveysAndFeedbackEmail:
          surveysAndFeedbackEmail ?? this.surveysAndFeedbackEmail,
      promotionalContentPush:
          promotionalContentPush ?? this.promotionalContentPush,
      promotionalContentEmail:
          promotionalContentEmail ?? this.promotionalContentEmail,
      newsletterEmail: newsletterEmail ?? this.newsletterEmail,
    );
  }

  @override
  List<Object?> get props => [
    newFollowerPush,
    newFollowerEmail,
    repostOfYourPostPush,
    repostOfYourPostEmail,
    newPostByFollowedPush,
    newPostByFollowedEmail,
    likesAndPlaysPush,
    likesAndPlaysEmail,
    commentOnPostPush,
    commentOnPostEmail,
    recommendedContentPush,
    recommendedContentEmail,
    newMessagePush,
    newMessageEmail,
    messagesFrom,
    featureUpdatesPush,
    featureUpdatesEmail,
    surveysAndFeedbackPush,
    surveysAndFeedbackEmail,
    promotionalContentPush,
    promotionalContentEmail,
    newsletterEmail,
  ];
}
