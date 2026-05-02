import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';

/// Fixture entity with all fields set to typical defaults, used as the
/// base for all [copyWith] and equality tests.
const tEntity = PrivacySettingsEntity(
  isPrivate: false,
  receiveMessageFromAnyone: true,
  showActivitiesInDiscovery: true,
  showAsTopFan: true,
  showTopFansOnTracks: true,
);

/// Tests for [PrivacySettingsEntity].
///
/// Verifies [Equatable] value equality across all 5 fields, individual
/// [copyWith] overrides per field, multi-field overrides, and that unchanged
/// fields are preserved through every copy operation.
void main() {
  group('PrivacySettingsEntity', () {
    test('supports value equality via Equatable', () {
      const same = PrivacySettingsEntity(
        isPrivate: false,
        receiveMessageFromAnyone: true,
        showActivitiesInDiscovery: true,
        showAsTopFan: true,
        showTopFansOnTracks: true,
      );
      expect(tEntity, same);
    });

    test('is not equal when a field differs', () {
      final different = tEntity.copyWith(isPrivate: true);
      expect(tEntity, isNot(different));
    });

    test('props contains all 5 fields', () {
      expect(tEntity.props.length, 5);
    });

    group('copyWith', () {
      test('returns identical entity when no overrides given', () {
        expect(tEntity.copyWith(), tEntity);
      });

      test('overrides isPrivate only', () {
        final updated = tEntity.copyWith(isPrivate: true);
        expect(updated.isPrivate, true);
        expect(
          updated.receiveMessageFromAnyone,
          tEntity.receiveMessageFromAnyone,
        );
        expect(
          updated.showActivitiesInDiscovery,
          tEntity.showActivitiesInDiscovery,
        );
        expect(updated.showAsTopFan, tEntity.showAsTopFan);
        expect(updated.showTopFansOnTracks, tEntity.showTopFansOnTracks);
      });

      test('overrides receiveMessageFromAnyone only', () {
        final updated = tEntity.copyWith(receiveMessageFromAnyone: false);
        expect(updated.receiveMessageFromAnyone, false);
        expect(updated.isPrivate, tEntity.isPrivate);
      });

      test('overrides showActivitiesInDiscovery only', () {
        final updated = tEntity.copyWith(showActivitiesInDiscovery: false);
        expect(updated.showActivitiesInDiscovery, false);
        expect(updated.isPrivate, tEntity.isPrivate);
      });

      test('overrides showAsTopFan only', () {
        final updated = tEntity.copyWith(showAsTopFan: false);
        expect(updated.showAsTopFan, false);
        expect(updated.isPrivate, tEntity.isPrivate);
      });

      test('overrides showTopFansOnTracks only', () {
        final updated = tEntity.copyWith(showTopFansOnTracks: false);
        expect(updated.showTopFansOnTracks, false);
        expect(updated.isPrivate, tEntity.isPrivate);
      });

      test('overrides multiple fields at once', () {
        final updated = tEntity.copyWith(
          isPrivate: true,
          showAsTopFan: false,
          showTopFansOnTracks: false,
        );
        expect(updated.isPrivate, true);
        expect(updated.showAsTopFan, false);
        expect(updated.showTopFansOnTracks, false);
        expect(
          updated.receiveMessageFromAnyone,
          tEntity.receiveMessageFromAnyone,
        );
        expect(
          updated.showActivitiesInDiscovery,
          tEntity.showActivitiesInDiscovery,
        );
      });
    });
  });
}
