class SentMessageRequestModel {
  final String? body;
  final String? trackId;
  final String? playlistId;

  SentMessageRequestModel({
    this.body,
    this.trackId,
    this.playlistId
  });

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'track_id': trackId,
      'playlistId': playlistId,
    }..removeWhere((key, value) => value == null);
  }
}