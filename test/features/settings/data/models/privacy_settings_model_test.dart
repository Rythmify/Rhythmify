import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/settings/data/models/privacy_settings_model.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';

/// Full JSON payload with all fields set to non-default values for thorough [fromJson] coverage.
const tFullJson = <String, dynamic>{
  'is_private': true,
  'receive_messages_from_anyone': false,
  'show_activities_in_discovery': false,
  'show_as_top_fan': false,
  'show_top_fans_on_tracks': false,
};

const tModel = PrivacySettingsModel(
  isPrivate: true,
  receiveMessageFromAnyone: false,
  showActivitiesInDiscovery: false,
  showAsTopFan: false,
  showTopFansOnTracks: false,
);

const tEntity = PrivacySettingsEntity(
  isPrivate: true,
  receiveMessageFromAnyone: false,
  showActivitiesInDiscovery: false,
  showAsTopFan: false,
  showTopFansOnTracks: false,
);

/// Tests for [PrivacySettingsModel].
///
/// Covers [fromJson] field mapping and defaults, [toPatch] diff computation
/// (only changed fields included, empty patch for identical models), [fromEntity]
/// copying, and [toDomain] producing an equal [PrivacySettingsEntity].
void main() {
  group('PrivacySettingsModel', () {
    group('fromJson', () {
      test('maps all fields from JSON correctly', () {
        final model = PrivacySettingsModel.fromJson(tFullJson);

        expect(model.isPrivate, true);
        expect(model.receiveMessageFromAnyone, false);
        expect(model.showActivitiesInDiscovery, false);
        expect(model.showAsTopFan, false);
        expect(model.showTopFansOnTracks, false);
      });

      test('applies defaults when all keys are absent', () {
        final model = PrivacySettingsModel.fromJson({});

        expect(model.isPrivate, false);
        expect(model.receiveMessageFromAnyone, true);
        expect(model.showActivitiesInDiscovery, true);
        expect(model.showAsTopFan, true);
        expect(model.showTopFansOnTracks, true);
      });

      test('defaults isPrivate to false when null', () {
        final model = PrivacySettingsModel.fromJson({'is_private': null});
        expect(model.isPrivate, false);
      });

      test('defaults receiveMessageFromAnyone to true when null', () {
        final model = PrivacySettingsModel.fromJson({
          'receive_messages_from_anyone': null,
        });
        expect(model.receiveMessageFromAnyone, true);
      });

      test('defaults showActivitiesInDiscovery to true when null', () {
        final model = PrivacySettingsModel.fromJson({
          'show_activities_in_discovery': null,
        });
        expect(model.showActivitiesInDiscovery, true);
      });

      test('defaults showAsTopFan to true when null', () {
        final model = PrivacySettingsModel.fromJson({'show_as_top_fan': null});
        expect(model.showAsTopFan, true);
      });

      test('defaults showTopFansOnTracks to true when null', () {
        final model = PrivacySettingsModel.fromJson({
          'show_top_fans_on_tracks': null,
        });
        expect(model.showTopFansOnTracks, true);
      });
    });

    group('toPatch', () {
      const base = PrivacySettingsModel(
        isPrivate: false,
        receiveMessageFromAnyone: true,
        showActivitiesInDiscovery: true,
        showAsTopFan: true,
        showTopFansOnTracks: true,
      );

      test('returns empty map when nothing changed', () {
        const current = PrivacySettingsModel(
          isPrivate: false,
          receiveMessageFromAnyone: true,
          showActivitiesInDiscovery: true,
          showAsTopFan: true,
          showTopFansOnTracks: true,
        );
        expect(current.toPatch(base), isEmpty);
      });

      test('includes receive_messages_from_anyone when changed', () {
        const current = PrivacySettingsModel(
          isPrivate: false,
          receiveMessageFromAnyone: false,
          showActivitiesInDiscovery: true,
          showAsTopFan: true,
          showTopFansOnTracks: true,
        );
        final patch = current.toPatch(base);
        expect(patch['receive_messages_from_anyone'], false);
        expect(patch.length, 1);
      });

      test('includes show_activities_in_discovery when changed', () {
        const current = PrivacySettingsModel(
          isPrivate: false,
          receiveMessageFromAnyone: true,
          showActivitiesInDiscovery: false,
          showAsTopFan: true,
          showTopFansOnTracks: true,
        );
        final patch = current.toPatch(base);
        expect(patch['show_activities_in_discovery'], false);
        expect(patch.length, 1);
      });

      test('includes show_as_top_fan when changed', () {
        const current = PrivacySettingsModel(
          isPrivate: false,
          receiveMessageFromAnyone: true,
          showActivitiesInDiscovery: true,
          showAsTopFan: false,
          showTopFansOnTracks: true,
        );
        final patch = current.toPatch(base);
        expect(patch['show_as_top_fan'], false);
        expect(patch.length, 1);
      });

      test('includes all three patchable fields when all changed', () {
        const current = PrivacySettingsModel(
          isPrivate: false,
          receiveMessageFromAnyone: false,
          showActivitiesInDiscovery: false,
          showAsTopFan: false,
          showTopFansOnTracks: true,
        );
        final patch = current.toPatch(base);
        expect(patch.length, 3);
        expect(patch['receive_messages_from_anyone'], false);
        expect(patch['show_activities_in_discovery'], false);
        expect(patch['show_as_top_fan'], false);
      });

      test('never includes is_private even when changed', () {
        const current = PrivacySettingsModel(
          isPrivate: true, // changed
          receiveMessageFromAnyone: true,
          showActivitiesInDiscovery: true,
          showAsTopFan: true,
          showTopFansOnTracks: true,
        );
        final patch = current.toPatch(base);
        expect(patch.containsKey('is_private'), false);
      });

      test('includes show_top_fans_on_tracks when changed', () {
        const current = PrivacySettingsModel(
          isPrivate: false,
          receiveMessageFromAnyone: true,
          showActivitiesInDiscovery: true,
          showAsTopFan: true,
          showTopFansOnTracks: false, // changed
        );
        final patch = current.toPatch(base);
        expect(patch['show_top_fans_on_tracks'], false);
        expect(patch.length, 1);
      });
    });

    group('fromEntity', () {
      test('creates model with same values as entity', () {
        final model = PrivacySettingsModel.fromEntity(tEntity);

        expect(model.isPrivate, tEntity.isPrivate);
        expect(
          model.receiveMessageFromAnyone,
          tEntity.receiveMessageFromAnyone,
        );
        expect(
          model.showActivitiesInDiscovery,
          tEntity.showActivitiesInDiscovery,
        );
        expect(model.showAsTopFan, tEntity.showAsTopFan);
        expect(model.showTopFansOnTracks, tEntity.showTopFansOnTracks);
      });
    });

    group('toDomain', () {
      test('returns a PrivacySettingsEntity with identical values', () {
        final entity = tModel.toDomain();

        expect(entity, isA<PrivacySettingsEntity>());
        expect(entity.isPrivate, tModel.isPrivate);
        expect(
          entity.receiveMessageFromAnyone,
          tModel.receiveMessageFromAnyone,
        );
        expect(
          entity.showActivitiesInDiscovery,
          tModel.showActivitiesInDiscovery,
        );
        expect(entity.showAsTopFan, tModel.showAsTopFan);
        expect(entity.showTopFansOnTracks, tModel.showTopFansOnTracks);
      });

      test('round-trip fromEntity → toDomain preserves all values', () {
        final model = PrivacySettingsModel.fromEntity(tEntity);
        final roundTripped = model.toDomain();
        expect(roundTripped, tEntity);
      });
    });
  });
}
