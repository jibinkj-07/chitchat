part of 'replying_message_cubit.dart';

class ReplyingMessageState extends Equatable {
  final bool isReplying;
  final String message;
  final String type;
  final String name;
  final bool isReplyingToMyMessage;
  const ReplyingMessageState({
    required this.isReplying,
    required this.isReplyingToMyMessage,
    required this.type,
    required this.name,
    required this.message,
  });

  @override
  List<Object> get props => [
        isReplying,
        isReplyingToMyMessage,
        message,
        type,
        name,
      ];
}

class ReplyingMessageInitial extends ReplyingMessageState {
  const ReplyingMessageInitial({
    required super.isReplying,
    required super.isReplyingToMyMessage,
    required super.message,
    required super.name,
    required super.type,
  });
}
