part of 'replying_message_cubit.dart';

class ReplyingMessageState extends Equatable {
  final bool isReplying;
  final String message;
  final String type;
  final bool isMine;
  const ReplyingMessageState({
    required this.isReplying,
    required this.isMine,
    required this.type,
    required this.message,
  });

  @override
  List<Object> get props => [
        isReplying,
        isMine,
        message,
        type,
      ];
}

class ReplyingMessageInitial extends ReplyingMessageState {
  const ReplyingMessageInitial({
    required super.isReplying,
    required super.isMine,
    required super.message,
    required super.type,
  });
}
