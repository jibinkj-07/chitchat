part of 'replying_message_cubit.dart';

class ReplyingMessageState extends Equatable {
  final bool isReplying;
  final String message;
  final bool isMine;
  const ReplyingMessageState({
    required this.isReplying,
    required this.isMine,
    required this.message,
  });

  @override
  List<Object> get props => [];
}

class ReplyingMessageInitial extends ReplyingMessageState {
  const ReplyingMessageInitial(
      {required super.isReplying,
      required super.isMine,
      required super.message});
}
