import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/get_related_tracks_usecase.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';

import 'test_helper.dart';

class MockPlaylistRemoteDatasource extends Mock
    implements PlaylistRemoteDatasource {}

void main() {
  late GetRelatedTracksUseCase useCase;
  late MockPlaylistRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockPlaylistRemoteDatasource();
    useCase = GetRelatedTracksUseCase(mockDatasource);
  });

  const tTrackId = '1';
  final tPlaylistTracks = [
    const PlaylistTrack(
      id: '1',
      title: 'Track 1',
      artistName: 'Artist 1',
      duration: Duration(seconds: 210),
      playCount: 100,
      position: 1,
      audioUrl: 'https://example.com/audio1.mp3',
    ),
  ];

  test(
    'should get related tracks from datasource and convert to tracks',
    () async {
      // arrange
      when(
        () => mockDatasource.fetchRelatedTracks(
          any(),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => tPlaylistTracks);

      // act
      final result = await useCase(tTrackId);

      // assert
      expect(result.length, 1);
      expect(result.first.id, tPlaylistTracks.first.id);
      expect(result.first.title, tPlaylistTracks.first.title);
      expect(result.first.artist, tPlaylistTracks.first.artistName);
      verify(() => mockDatasource.fetchRelatedTracks(tTrackId)).called(1);
      verifyNoMoreInteractions(mockDatasource);
    },
  );

  test('should throw an exception when datasource fails', () async {
    // arrange
    when(
      () =>
          mockDatasource.fetchRelatedTracks(any(), limit: any(named: 'limit')),
    ).thenThrow(Exception());

    // act
    final call = useCase(tTrackId);

    // assert
    expect(() => call, throwsA(isA<Exception>()));
    verify(() => mockDatasource.fetchRelatedTracks(tTrackId)).called(1);
    verifyNoMoreInteractions(mockDatasource);
  });
}
