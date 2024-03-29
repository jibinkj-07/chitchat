class MessageItem {
  final String messageId;
  final String message;
  final String currentUserid;
  final String targetUserid;
  final bool isReplied;
  final String repliedToMessage;
  final bool read;
  final DateTime? readTime;
  final DateTime time;
  final String type;
  final String targetUsername;
  final String replyingParentMessageType;
  final bool isMe;
  final bool isRepliedToMyself;
  final String caption;
  const MessageItem({
    required this.messageId,
    required this.message,
    required this.time,
    required this.isReplied,
    required this.type,
    required this.caption,
    required this.repliedToMessage,
    required this.replyingParentMessageType,
    required this.currentUserid,
    required this.targetUserid,
    required this.isMe,
    required this.read,
    required this.targetUsername,
    required this.isRepliedToMyself,
    this.readTime,
  });
}
