class SentMessageRequestModel {
  final String? body;
  final String? trackId;
  final String? likedId;

  SentMessageRequestModel({
    this.body,
    this.likedId,
    this.trackId
  });

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'embedType': trackId,
      'embedId': likedId,
    }..removeWhere((key, value) => value == null);
  }
}