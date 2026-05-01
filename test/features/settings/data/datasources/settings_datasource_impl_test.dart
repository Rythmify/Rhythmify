import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/settings/data/datasources/settings_datasources_impl.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

const tPrivacyJson = <String, dynamic>{
  'is_private': false,
  'receive_messages_from_anyone': true,
  'show_activities_in_discovery': true,
  'show_as_top_fan': true,
  'show_top_fans_on_tracks': true,
};

const tNotifJson = <String, dynamic>{
  'new_follower_push': true,
  'new_follower_email': true,
  'repost_of_your_post_push': true,
  'repost_of_your_post_email': true,
  'new_post_by_followed_push': true,
  'new_post_by_followed_email': true,
  'likes_and_plays_push': true,
  'likes_and_plays_email': true,
  'comment_on_post_push': true,
  'comment_on_post_email': true,
  'recommended_content_push': true,
  'recommended_content_email': true,
  'new_message_push': true,
  'new_message_email': true,
  'messages_from': 'everyone',
  'feature_updates_push': true,
  'feature_updates_email': true,
  'surveys_and_feedback_push': true,
  'surveys_and_feedback_email': true,
  'promotional_content_push': true,
  'promotional_content_email': true,
  'newsletter_email': true,
};

const tNotifModel = NotificationPreferencesModel(
  newFollowerPush: true,
  newFollowerEmail: true,
  repostOfYourPostPush: true,
  repostOfYourPostEmail: true,
  newPostByFollowedPush: true,
  newPostByFollowedEmail: true,
  likesAndPlaysPush: true,
  likesAndPlaysEmail: true,
  commentOnPostPush: true,
  commentOnPostEmail: true,
  recommendedContentPush: true,
  recommendedContentEmail: true,
  newMessagePush: true,
  newMessageEmail: true,
  messagesFrom: MessagesFrom.everyone,
  featureUpdatesPush: true,
  featureUpdatesEmail: true,
  surveysAndFeedbackPush: true,
  surveysAndFeedbackEmail: true,
  promotionalContentPush: true,
  promotionalContentEmail: true,
  newsletterEmail: true,
);

Response<dynamic> _privacyResponse() => Response(
  requestOptions: RequestOptions(path: '/users/me/privacy-settings'),
  statusCode: 200,
  data: {'data': tPrivacyJson},
);

Response<dynamic> _notifResponse() => Response(
  requestOptions: RequestOptions(path: '/notifications/preferences'),
  statusCode: 200,
  data: {'data': tNotifJson},
);

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late SettingsDatasourcesImpl datasource;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    datasource = SettingsDatasourcesImpl(mockApiClient);

    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('SettingsDatasourcesImpl', () {
    group('getPrivacySettings', () {
      test('performs GET /users/me/privacy-settings and parses response', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => _privacyResponse());

        final result = await datasource.getPrivacySettings();

        expect(result, isA<PrivacySettingsModel>());
        expect(result.isPrivate, false);
        expect(result.receiveMessageFromAnyone, true);
        verify(() => mockDio.get('/users/me/privacy-settings')).called(1);
      });

      test('returns defaults when response data is null', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/users/me/privacy-settings'),
            statusCode: 200,
            data: {'data': null},
          ),
        );

        final result = await datasource.getPrivacySettings();

        expect(result.isPrivate, false);
        expect(result.receiveMessageFromAnyone, true);
      });

      test('returns defaults when response data is not a Map', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/users/me/privacy-settings'),
            statusCode: 200,
            data: 'invalid',
          ),
        );

        final result = await datasource.getPrivacySettings();

        expect(result.isPrivate, false);
        expect(result.receiveMessageFromAnyone, true);
      });
    });

    group('patchPrivacySettings', () {
      test('performs PATCH /users/me/privacy-settings with given fields', () async {
        const fields = <String, dynamic>{'receive_messages_from_anyone': false};

        when(() => mockDio.patch(any(), data: any(named: 'data')))
            .thenAnswer((_) async => _privacyResponse());

        final result = await datasource.patchPrivacySettings(fields);

        expect(result, isA<PrivacySettingsModel>());
        verify(
          () => mockDio.patch(
            '/users/me/privacy-settings',
            data: fields,
          ),
        ).called(1);
      });

      test('returns defaults when patch response data is null', () async {
        when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/users/me/privacy-settings'),
            statusCode: 200,
            data: {'data': null},
          ),
        );

        final result = await datasource.patchPrivacySettings({});

        expect(result.isPrivate, false);
      });

      test('returns defaults when patch response is not a Map', () async {
        when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/users/me/privacy-settings'),
            statusCode: 200,
            data: 42,
          ),
        );

        final result = await datasource.patchPrivacySettings({});

        expect(result.isPrivate, false);
      });
    });

    group('getNotificationPreferences', () {
      test('performs GET /notifications/preferences and parses response', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => _notifResponse());

        final result = await datasource.getNotificationPreferences();

        expect(result, isA<NotificationPreferencesModel>());
        expect(result.newFollowerPush, true);
        expect(result.messagesFrom, MessagesFrom.everyone);
        verify(() => mockDio.get('/notifications/preferences')).called(1);
      });
    });

    group('updateNotificationPreferences', () {
      test('performs PATCH /notifications/preferences with serialised model', () async {
        when(() => mockDio.patch(any(), data: any(named: 'data')))
            .thenAnswer((_) async => _notifResponse());

        final result = await datasource.updateNotificationPreferences(tNotifModel);

        expect(result, isA<NotificationPreferencesModel>());
        expect(result.messagesFrom, MessagesFrom.everyone);

        final captured = verify(
          () => mockDio.patch(
            '/notifications/preferences',
            data: captureAny(named: 'data'),
          ),
        ).captured.single as Map<String, dynamic>;
        expect(captured['new_follower_push'], true);
        expect(captured['messages_from'], 'everyone');
      });
    });

    group('deleteMyAccount', () {
      test('performs DELETE /users/me', () async {
        when(() => mockDio.delete(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/users/me'),
            statusCode: 204,
          ),
        );

        await datasource.deleteMyAccount();

        verify(() => mockDio.delete('/users/me')).called(1);
      });
    });
  });
}
