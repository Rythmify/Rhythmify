// import '../../domain/entities/track_draft.dart';
// class TrackModel extends TrackEntity{
//     const TrackModel({
//     super.id,
//     required super.title,
//     required super.artistName,
//     required super.genre,
//     super.description,
//     super.audioUrl,
//     super.coverImageUrl,
//     required super.durationSeconds,
//     super.uploadedAt,
//     super.uploadedBy,
//   });

//   factory TrackModel.fromJson(Map<String, dynamic> json) {
//   return TrackModel(
//     id:              json['id']?.toString(),
//     title:           json['title']          as String? ?? '',
//     artistName:      json['artistName']     as String? ?? '',
//     genre:           json['genre']          as String? ?? '',
//     description:     json['description']    as String?,
//     audioUrl:        json['audioUrl']       as String?,
//     coverImageUrl:   json['coverImageUrl']  as String?,
//     durationSeconds: (json['duration']      as num?)?.toInt() ?? 0,
//     uploadedAt:      json['uploadedAt'] != null
//         ? DateTime.tryParse(json['uploadedAt'] as String)
//         : null,
//     uploadedBy:      json['uploadedBy']     as String?,
//   );
// }

//  Map<String, String> toFormFields() {
//     return {
//       'title':       title,
//       'artistName':  artistName,
//       'genre':       genre,
//       'description': description ?? '',
//       'duration':    durationSeconds.toString(),
//       if (uploadedBy != null)    'userId':        uploadedBy!,
//       if (coverImageUrl != null) 'coverImageUrl': coverImageUrl!,
//     };
//   }

//   TrackEntity toEntity() => TrackEntity(
//     id:              id,
//     title:           title,
//     artistName:      artistName,
//     genre:           genre,
//     description:     description,
//     audioUrl:        audioUrl,
//     coverImageUrl:   coverImageUrl,
//     durationSeconds: durationSeconds,
//     uploadedAt:      uploadedAt,
//     uploadedBy:      uploadedBy,
//   );
// }