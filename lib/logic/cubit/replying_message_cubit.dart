import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'replying_message_state.dart';

class ReplyingMessageCubit extends Cubit<ReplyingMessageState> {
  ReplyingMessageCubit()
      : super(
          const ReplyingMessageInitial(
            message: '',
            isReplyingToMyMessage: false,
            isReplying: false,
            parentMessageType: '',
            name: '',
          ),
        );

  void reply({
    required bool isReplying,
    required bool isMine,
    required String message,
    required String parentMessageType,
    required String name,
  }) {
    emit(
      ReplyingMessageState(
        isReplying: isReplying,
        isReplyingToMyMessage: isMine,
        message: message,
        parentMessageType: parentMessageType,
        name: name,
      ),
    );
  }

  void clearMessage() {
    emit(const ReplyingMessageState(
      isReplyingToMyMessage: false,
      isReplying: false,
      message: '',
      parentMessageType: '',
      name: '',
    ));
  }
}
