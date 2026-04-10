import '../../../../core/domain/entities/track.dart';

class GenreTabTracks {
  final String genreId;
  final String genreName;
  final List<Track> tracks;

  const GenreTabTracks({
    required this.genreId,
    required this.genreName,
    required this.tracks,
  });
}
