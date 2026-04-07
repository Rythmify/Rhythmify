/// Data model representing a request to send a message or start a conversation.
///
/// This model encapsulates the optional fields that can be included when
/// initiating communication, such as a text body, a track, or a playlist.
class SentMessageRequestModel {
  /// The optional text content of the message.
  final String? body;

  /// The optional identifier of a track to be shared.
  final String? trackId;

  /// The optional identifier of a playlist to be shared.
  final String? playlistId;

  SentMessageRequestModel({this.body, this.trackId, this.playlistId});

  /// Converts this [SentMessageRequestModel] instance into a JSON object.
  ///
  /// Null values are removed from the resulting map to ensure a clean request.
  Map<String, dynamic> toJson() {
    final data= <String, dynamic>{};
    if (body != null) data['body'] = body;
    if (trackId != null) data['resource'] = {'type': 'track', 'id': trackId};
    if (playlistId != null) data['resource'] = {'type': 'playlist', 'id': playlistId};
    return data;
  }
}
