class PotentialConversation {
  final String participantId;
  final String participantName;
  final int? followersCount;
  final String? location;
  final String? avatar;

  PotentialConversation({
    required this.participantId,
    required this.participantName,
    this.followersCount,
    this.location,
    this.avatar,
  });
}
