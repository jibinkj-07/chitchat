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
            type: '',
            name: '',
          ),
        );

  void reply({
    required bool isReplying,
    required bool isMine,
    required String message,
    required String type,
    required String name,
  }) {
    emit(
      ReplyingMessageState(
        isReplying: isReplying,
        isMine: isMine,
        message: message,
        type: type,
        name: name,
      ),
    );
  }

  void clearMessage() {
    emit(const ReplyingMessageState(
      isMine: false,
      isReplying: false,
      message: '',
      type: '',
      name: '',
    ));
  }
}
