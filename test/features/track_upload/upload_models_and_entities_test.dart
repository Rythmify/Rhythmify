import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/track_upload/data/models/upload_response_model.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';

void main() {
  group('UploadResponseModel', () {
    test('parses direct upload response', () {
      final result = UploadResponseModel.fromJson({
        'id': 'track-1',
        'status': 'ready',
      });

      expect(result.id, 'track-1');
      expect(result.status, 'ready');
    });

    test('parses nested track response and defaults processing status', () {
      final result = UploadResponseModel.fromJson({
        'track': {'id': 'track-2'},
      });

      expect(result.id, 'track-2');
      expect(result.status, 'processing');
    });

    test('handles malformed response without throwing', () {
      final result = UploadResponseModel.fromJson({'message': 'created'});

      expect(result.id, '');
      expect(result.status, 'processing');
    });
  });

  group('TrackDraft', () {
    test('checklistCount reflects filled metadata and artwork', () {
      final draft = TrackDraft(
        artistId: 'user-1',
        localAudioPath: '/music/audio.mp3',
        duration: const Duration(minutes: 3),
        title: 'Song',
        artist: 'Artist',
        genre: 'Pop',
        localArtworkPath: '/covers/song.jpg',
        description: 'Description',
      );

      expect(draft.checklistCount, 4);
    });

    test('remote artwork counts and blank fields are ignored', () {
      final draft = TrackDraft(
        artistId: 'user-1',
        localAudioPath: '/music/audio.mp3',
        duration: const Duration(minutes: 3),
        remoteArtworkUrl: 'https://cdn/cover.jpg',
        title: '  ',
        artist: 'Artist',
        genre: '',
      );

      expect(draft.checklistCount, 1);
    });

    test(
      'copyWith preserves state and supports clearing optional media/text',
      () {
        final original = TrackDraft(
          trackId: 'track-1',
          artistId: 'user-1',
          localAudioPath: '/music/audio.mp3',
          duration: const Duration(minutes: 3),
          title: 'Old',
          artist: 'Artist',
          genre: 'Pop',
          localArtworkPath: '/covers/song.jpg',
          description: 'desc',
          caption: 'caption',
          tags: const ['demo'],
          isPublic: false,
          isHidden: true,
          geoRestrictionType: 'include',
          geoRegions: const ['EG'],
          status: UploadStatus.uploading,
          uploadProgress: .4,
        );

        final updated = original.copyWith(
          title: 'New',
          clearArtwork: true,
          clearDescription: true,
          clearCaption: true,
          status: UploadStatus.success,
          uploadProgress: 1,
        );

        expect(updated.trackId, 'track-1');
        expect(updated.title, 'New');
        expect(updated.localArtworkPath, isNull);
        expect(updated.description, isNull);
        expect(updated.caption, isNull);
        expect(updated.tags, ['demo']);
        expect(updated.isPublic, isFalse);
        expect(updated.isHidden, isTrue);
        expect(updated.geoRestrictionType, 'include');
        expect(updated.geoRegions, ['EG']);
        expect(updated.status, UploadStatus.success);
        expect(updated.uploadProgress, 1);
      },
    );
  });
}
