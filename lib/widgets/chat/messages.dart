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
import 'package:iconsax/iconsax.dart';
import '../../logic/cubit/replying_message_cubit.dart';
import '../../utils/message_Item.dart';

class Messages extends StatefulWidget {
  final MessageItem messageItem;
  final String sender;
  final String target;
  Messages({
    super.key,
    required this.messageItem,
    required this.sender,
    required this.target,
  });

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late TextEditingController editMessageController;

  @override
  void initState() {
    editMessageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    editMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.messageItem.isMe) {
      FirebaseChatOperations().readMessage(
        messageId: widget.messageItem.messageId,
        senderId: widget.messageItem.currentUserid,
        targetId: widget.messageItem.targetUserid,
      );
    }

    final messageTime =
        ChatFuntions(time: widget.messageItem.time).formattedTime();

//MAIN SECTION
    return Dismissible(
        key: ValueKey(widget.messageItem.messageId),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            context.read<ReplyingMessageCubit>().reply(
                  isReplying: true,
                  isMine: widget.messageItem.isMe,
                  message: widget.messageItem.message,
                  parentMessageType: widget.messageItem.type,
                  name: widget.messageItem.targetUsername,
                );
          }
          return null;
        },
        child: InkWell(
          onLongPress: () {
            deleteMessage(
              context: context,
              messageItem: widget.messageItem,
            );
          },
          child: widget.messageItem.isMe
              ? widget.messageItem.isReplied
                  ? RepliedSenderChatBubble(
                      messageItem: widget.messageItem,
                      messageTime: messageTime,
                    )
                  : SenderChatBubble(
                      messageItem: widget.messageItem,
                      messageTime: messageTime,
                    )
              : widget.messageItem.isReplied
                  ? RepliedReceivedChatBubble(
                      messageItem: widget.messageItem,
                      messageTime: messageTime,
                    )
                  : ReceivedMessageBubble(
                      messageItem: widget.messageItem,
                      messageTime: messageTime,
                    ),
        ));
  }

  editMessage({
    required BuildContext context,
    required MessageItem messageItem,
  }) {
    //for editing message
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                editMessageController.text == messageItem.message;
              },
              style: TextButton.styleFrom(
                  foregroundColor: AppColors().primaryColor),
              child: const Text('Cancel'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoTextField(
                controller: editMessageController,
                autofocus: true,
                minLines: 1,
                maxLines: 5,
                onSubmitted: (value) {
                  if (value.trim().isEmpty) {
                    Navigator.of(context).pop();
                  } else {
                    FirebaseChatOperations().editMessage(
                      senderid: widget.sender,
                      targetid: widget.target,
                      messageId: messageItem.messageId,
                      message: value.trim(),
                    );
                    Navigator.of(context).pop();
                  }
                },
                textCapitalization: TextCapitalization.sentences,
                placeholder: "edit message",
                clearButtonMode: OverlayVisibilityMode.editing,
                textInputAction: TextInputAction.done,
                cursorColor: AppColors().primaryColor,
                decoration: const BoxDecoration(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //showing dialog box for clearing chat
  deleteMessage({
    required BuildContext context,
    required MessageItem messageItem,
  }) {
    FocusScope.of(context).unfocus();
    AppColors appColors = AppColors();
    FirebaseChatOperations firebaseChatOperations = FirebaseChatOperations();
    final content = messageItem.type == 'text'
        ? messageItem.message.length > 30
            ? '${messageItem.message.substring(0, 27)}...'
            : messageItem.message
        : messageItem.type == 'image'
            ? 'Image message'
            : 'Voice message';

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
                const Expanded(
                  child: Text(
                    'Deleting message',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // show the dialog
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 0),
              if (messageItem.isMe && messageItem.type == 'text')
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      editMessageController =
                          TextEditingController(text: messageItem.message);
                      editMessage(context: context, messageItem: messageItem);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: appColors.textColorBlack,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text(
                      'Edit message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              if (messageItem.isMe)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
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
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text(
                      'Delete for all',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
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
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Text(
                    'Delete for me',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
