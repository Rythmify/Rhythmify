/// Represents a user that the current user can start a conversation with.
///
/// This entity holds basic information about a potential chat participant,
/// typically retrieved during a user search or from a followers list.
class PotentialConversation {
  /// The unique identifier of the potential participant.
  final String participantId;

  /// The name of the potential participant.
  final String participantName;

  /// The number of followers the potential participant has.
  final int? followersCount;

  /// The geographic location of the potential participant.
  final String? location;

  /// The optional URL to the potential participant's avatar image.
  final String? avatar;

  PotentialConversation({
    required this.participantId,
    required this.participantName,
    this.followersCount,
    this.location,
    this.avatar,
  });
}
