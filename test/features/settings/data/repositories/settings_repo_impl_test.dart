import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/settings/data/datasources/settings_remote_datasources.dart';
import 'package:rythmify/features/settings/data/models/notification_preferences_model.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';
import 'package:rythmify/features/settings/data/repositories/settings_repo_impl.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';

/// Mock [SettingsRemoteDatasources] for stubbing all datasource calls in repo tests.
class MockSettingsRemoteDatasources extends Mock
    implements SettingsRemoteDatasources {}

const tPrivacyModel = PrivacySettingsModel(
  isPrivate: false,
  receiveMessageFromAnyone: true,
  showActivitiesInDiscovery: true,
  showAsTopFan: true,
  showTopFansOnTracks: true,
);

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

const tNotifEntity = NotificationPreferencesEntity(
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

/// Tests for [SettingsRepoImpl].
///
/// Verifies that [getPrivacySettings] and [getNotificationPreferences] delegate
/// to the datasource and map results to domain entities. Verifies that
/// [updatePrivacySettings] skips the datasource call when the patch diff is
/// empty (unchanged settings), and that [updateNotificationPreferences] and
/// [deleteMyAccount] forward to the datasource with correct arguments.
/// Exception propagation is verified for all methods.
void main() {
  late MockSettingsRemoteDatasources mockDatasource;
  late SettingsRepoImpl repo;

  setUp(() {
    mockDatasource = MockSettingsRemoteDatasources();
    repo = SettingsRepoImpl(mockDatasource);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(tNotifModel);
  });

  group('SettingsRepoImpl', () {
    group('getPrivacySettings', () {
      test(
        'returns PrivacySettingsEntity mapped from datasource model',
        () async {
          when(
            () => mockDatasource.getPrivacySettings(),
          ).thenAnswer((_) async => tPrivacyModel);

          final result = await repo.getPrivacySettings();

          expect(result, isA<PrivacySettingsEntity>());
          expect(result.isPrivate, tPrivacyModel.isPrivate);
          expect(
            result.receiveMessageFromAnyone,
            tPrivacyModel.receiveMessageFromAnyone,
          );
          expect(
            result.showActivitiesInDiscovery,
            tPrivacyModel.showActivitiesInDiscovery,
          );
          expect(result.showAsTopFan, tPrivacyModel.showAsTopFan);
          expect(result.showTopFansOnTracks, tPrivacyModel.showTopFansOnTracks);
          verify(() => mockDatasource.getPrivacySettings()).called(1);
          verifyNoMoreInteractions(mockDatasource);
        },
      );

      test('propagates exceptions from datasource', () {
        when(
          () => mockDatasource.getPrivacySettings(),
        ).thenThrow(Exception('Network error'));

        expect(() => repo.getPrivacySettings(), throwsException);
      });
    });

    group('updatePrivacySettings', () {
      const previous = PrivacySettingsEntity(
        isPrivate: false,
        receiveMessageFromAnyone: true,
        showActivitiesInDiscovery: true,
        showAsTopFan: true,
        showTopFansOnTracks: true,
      );

      test(
        'returns updated entity without calling datasource when nothing changed',
        () async {
          const updated = previous;

          final result = await repo.updatePrivacySettings(previous, updated);

          expect(result, updated);
          verifyNever(() => mockDatasource.patchPrivacySettings(any()));
        },
      );

      test(
        'calls patchPrivacySettings when receiveMessageFromAnyone changes',
        () async {
          const updated = PrivacySettingsEntity(
            isPrivate: false,
            receiveMessageFromAnyone: false,
            showActivitiesInDiscovery: true,
            showAsTopFan: true,
            showTopFansOnTracks: true,
          );

          when(
            () => mockDatasource.patchPrivacySettings(any()),
          ).thenAnswer((_) async => tPrivacyModel);

          final result = await repo.updatePrivacySettings(previous, updated);

          expect(result, isA<PrivacySettingsEntity>());
          final captured =
              verify(
                    () => mockDatasource.patchPrivacySettings(captureAny()),
                  ).captured.single
                  as Map<String, dynamic>;
          expect(captured['receive_messages_from_anyone'], false);
          expect(captured.containsKey('is_private'), false);
        },
      );

      test(
        'calls patchPrivacySettings when showActivitiesInDiscovery changes',
        () async {
          const updated = PrivacySettingsEntity(
            isPrivate: false,
            receiveMessageFromAnyone: true,
            showActivitiesInDiscovery: false,
            showAsTopFan: true,
            showTopFansOnTracks: true,
          );

          when(
            () => mockDatasource.patchPrivacySettings(any()),
          ).thenAnswer((_) async => tPrivacyModel);

          await repo.updatePrivacySettings(previous, updated);

          final captured =
              verify(
                    () => mockDatasource.patchPrivacySettings(captureAny()),
                  ).captured.single
                  as Map<String, dynamic>;
          expect(captured['show_activities_in_discovery'], false);
        },
      );

      test('calls patchPrivacySettings when showAsTopFan changes', () async {
        const updated = PrivacySettingsEntity(
          isPrivate: false,
          receiveMessageFromAnyone: true,
          showActivitiesInDiscovery: true,
          showAsTopFan: false,
          showTopFansOnTracks: true,
        );

        when(
          () => mockDatasource.patchPrivacySettings(any()),
        ).thenAnswer((_) async => tPrivacyModel);

        await repo.updatePrivacySettings(previous, updated);

        final captured =
            verify(
                  () => mockDatasource.patchPrivacySettings(captureAny()),
                ).captured.single
                as Map<String, dynamic>;
        expect(captured['show_as_top_fan'], false);
      });

      test('propagates exceptions from patchPrivacySettings', () {
        const updated = PrivacySettingsEntity(
          isPrivate: false,
          receiveMessageFromAnyone: false,
          showActivitiesInDiscovery: true,
          showAsTopFan: true,
          showTopFansOnTracks: true,
        );

        when(
          () => mockDatasource.patchPrivacySettings(any()),
        ).thenThrow(Exception('Server error'));

        expect(
          () => repo.updatePrivacySettings(previous, updated),
          throwsException,
        );
      });
    });

    group('getNotificationPreferences', () {
      test('returns NotificationPreferencesEntity from datasource', () async {
        when(
          () => mockDatasource.getNotificationPreferences(),
        ).thenAnswer((_) async => tNotifModel);

        final result = await repo.getNotificationPreferences();

        expect(result, isA<NotificationPreferencesEntity>());
        expect(result.newFollowerPush, tNotifModel.newFollowerPush);
        expect(result.messagesFrom, tNotifModel.messagesFrom);
        expect(result.newsletterEmail, tNotifModel.newsletterEmail);
        verify(() => mockDatasource.getNotificationPreferences()).called(1);
        verifyNoMoreInteractions(mockDatasource);
      });

      test('propagates exceptions from datasource', () {
        when(
          () => mockDatasource.getNotificationPreferences(),
        ).thenThrow(Exception('Timeout'));

        expect(() => repo.getNotificationPreferences(), throwsException);
      });
    });

    group('updateNotificationPreferences', () {
      test('calls datasource and returns mapped entity', () async {
        when(
          () => mockDatasource.updateNotificationPreferences(any()),
        ).thenAnswer((_) async => tNotifModel);

        final result = await repo.updateNotificationPreferences(tNotifEntity);

        expect(result, isA<NotificationPreferencesEntity>());
        expect(result.newFollowerPush, tNotifModel.newFollowerPush);
        expect(result.messagesFrom, tNotifModel.messagesFrom);
        verify(
          () => mockDatasource.updateNotificationPreferences(any()),
        ).called(1);
        verifyNoMoreInteractions(mockDatasource);
      });

      test(
        'passes a model built from the given entity to datasource',
        () async {
          when(
            () => mockDatasource.updateNotificationPreferences(any()),
          ).thenAnswer((_) async => tNotifModel);

          await repo.updateNotificationPreferences(tNotifEntity);

          final captured =
              verify(
                    () => mockDatasource.updateNotificationPreferences(
                      captureAny(),
                    ),
                  ).captured.single
                  as NotificationPreferencesModel;
          expect(captured.newFollowerPush, tNotifEntity.newFollowerPush);
          expect(captured.messagesFrom, tNotifEntity.messagesFrom);
        },
      );

      test('propagates exceptions from datasource', () {
        when(
          () => mockDatasource.updateNotificationPreferences(any()),
        ).thenThrow(Exception('Bad request'));

        expect(
          () => repo.updateNotificationPreferences(tNotifEntity),
          throwsException,
        );
      });
    });

    group('deleteMyAccount', () {
      test('delegates to datasource.deleteMyAccount', () async {
        when(() => mockDatasource.deleteMyAccount()).thenAnswer((_) async {});

        await repo.deleteMyAccount();

        verify(() => mockDatasource.deleteMyAccount()).called(1);
        verifyNoMoreInteractions(mockDatasource);
      });

      test('propagates exceptions from datasource', () {
        when(
          () => mockDatasource.deleteMyAccount(),
        ).thenThrow(Exception('Forbidden'));

        expect(() => repo.deleteMyAccount(), throwsException);
      });
    });
  });
}
