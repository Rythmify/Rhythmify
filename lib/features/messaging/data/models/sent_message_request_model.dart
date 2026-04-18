/// Data model representing a request to send a message or start a conversation.
///
/// This model encapsulates the optional fields that can be included when
/// initiating communication, such as a text body, a track, or a playlist.
class SentMessageRequestModel {
  /// The optional text content of the message.
  final String? body;

  /// The optional identifier of a track to be shared.
  final String? embedId;

  /// The optional identifier of a playlist to be shared.
  final String? embedType;

  SentMessageRequestModel({this.body, this.embedId, this.embedType});

  /// Converts this [SentMessageRequestModel] instance into a JSON object.
  ///
  /// Null values are removed from the resulting map to ensure a clean request.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (body != null) data['body'] = body;
    if (embedId != null) {
      data['resource'] = {
        'type': embedType == 'track' ? 'track' : 'playlist',
        'id': embedId,
      };
    }
    print('📤 sendMessage JSON: $data');
    return data;
  }
}
