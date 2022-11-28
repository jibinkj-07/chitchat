import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'replying_message_state.dart';

class ReplyingMessageCubit extends Cubit<ReplyingMessageState> {
  ReplyingMessageCubit()
      : super(
          const ReplyingMessageInitial(
            message: '',
            isMine: false,
            isReplying: false,
          ),
        );

  void reply({
    required isReplying,
    required isMine,
    required message,
  }) {
    emit(
      ReplyingMessageState(
        isReplying: isReplying,
        isMine: isMine,
        message: message,
      ),
    );
  }

  void clearMessage() {
    emit(const ReplyingMessageState(
        isMine: false, isReplying: false, message: ''));
  }
}
