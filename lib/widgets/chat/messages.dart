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
        child: InkWell(
          onLongPress: () {
            deleteMessage(
              context: context,
              messageItem: messageItem,
            );
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
        ));
  }

  //showing dialog box for clearing chat
  deleteMessage({
    required BuildContext context,
    required MessageItem messageItem,
  }) {
    FocusScope.of(context).unfocus();
    AppColors appColors = AppColors();
    FirebaseChatOperations firebaseChatOperations = FirebaseChatOperations();

    showProgress(BuildContext context1) {
      showDialog(
        context: context1,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appColors.redColor,
                    // backgroundColor: appColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                const Text(
                  'Deleting message',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final content = messageItem.type == 'text'
            ? messageItem.message.length > 20
                ? '${messageItem.message.substring(0, 17)}...'
                : messageItem.message
            : messageItem.type == 'image'
                ? 'Image message'
                : 'Voice message';
        return
            //clearing chat history dialog box
            AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          title: const Text(
            "Delete message",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: messageItem.isMe
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                //for all button
                if (messageItem.isMe)
                  TextButton(
                    onPressed: () async {
                      final nav = Navigator.of(ctx);
                      nav.pop(true);
                      showProgress(ctx);
                      await firebaseChatOperations.deleteMessageForAll(
                        messageId: messageItem.messageId,
                        type: messageItem.type,
                        senderId: messageItem.currentUserid,
                        targetId: messageItem.targetUserid,
                      );
                      nav.pop(true);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: appColors.redColor,
                    ),
                    child: const Text("Delete for all"),
                  ),
                //for me button
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    nav.pop(true);
                    showProgress(ctx);
                    await firebaseChatOperations.deleteMessageForMe(
                      messageId: messageItem.messageId,
                      senderId: messageItem.currentUserid,
                      targetId: messageItem.targetUserid,
                      type: messageItem.type,
                      message: 'Message deleted for me',
                      deleteForAll: false,
                    );
                    nav.pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.redColor,
                  ),
                  child: const Text("Delete for me"),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
