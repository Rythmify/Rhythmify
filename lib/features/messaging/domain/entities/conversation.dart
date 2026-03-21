class Conversation{
   final String conversationId;
   final String participantId;
   final String participantName;
   final String? participantAvatar;
   final String lastMessagePreview;
   final DateTime lastMessageDate;
   final int unReadCount;
   
   Conversation({
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.lastMessagePreview,
    required this.lastMessageDate,
    required this.unReadCount
   });
}