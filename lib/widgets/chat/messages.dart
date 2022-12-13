import 'dart:developer';
import 'package:chitchat/logic/database/firebase_chat_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/chat_functions.dart';
import 'package:chitchat/widgets/chat/chat%20bubbles/received_chat_bubble.dart';
import 'package:chitchat/widgets/chat/chat%20bubbles/replied_received_chat_bubble.dart';
import 'package:chitchat/widgets/chat/chat%20bubbles/replied_sender_chat_bubble.dart';
import 'package:chitchat/widgets/chat/chat%20bubbles/sender_chat_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/replying_message_cubit.dart';
import '../../utils/message_Item.dart';

class Messages extends StatelessWidget {
  final MessageItem messageItem;
  Messages({
    super.key,
    required this.messageItem,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    if (!messageItem.isMe) {
      FirebaseChatOperations().readMessage(
        messageId: messageItem.messageId,
        senderId: messageItem.currentUserid,
        targetId: messageItem.targetUserid,
      );
    }

    final messageTime = ChatFuntions(time: messageItem.time).formattedTime();

//MAIN SECTION
    return Dismissible(
      key: ValueKey(messageItem.messageId),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          context.read<ReplyingMessageCubit>().reply(
                isReplying: true,
                isMine: messageItem.isMe,
                message: messageItem.message,
                parentMessageType: messageItem.type,
                name: messageItem.targetUsername,
              );
        }
        return null;
      },
      child: messageItem.isMe
          ? messageItem.isReplied
              ? RepliedSenderChatBubble(
                  messageItem: messageItem,
                  messageTime: messageTime,
                )
              : SenderChatBubble(
                  messageItem: messageItem,
                  messageTime: messageTime,
                )
          : messageItem.isReplied
              ? RepliedReceivedChatBubble(
                  messageItem: messageItem,
                  messageTime: messageTime,
                )
              : ReceivedMessageBubble(
                  messageItem: messageItem,
                  messageTime: messageTime,
                ),
    );
  }
}
