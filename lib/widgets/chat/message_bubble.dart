import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/cubit/replying_message_cubit.dart';
import 'package:chitchat/widgets/chat/imageMessage_preview.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/database/firebase_operations.dart';
import '../../utils/app_colors.dart';
import '../../utils/message_Item.dart';

class MessageBubble extends StatelessWidget {
  final MessageItem messageItem;
  const MessageBubble({
    super.key,
    required this.messageItem,
  });

  //date difference calculation function
  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    AppColors appColors = AppColors();

    if (!messageItem.isMe) {
      FirebaseOperations().changeReadMessageStatus(
        messageId: messageItem.messageId,
        senderId: messageItem.currentUserid,
        targetId: messageItem.targetUserid,
      );
    }
    final timeDiff = calculateDifference(messageItem.time);
    String messageTime = '';
    if (timeDiff == 0) {
      messageTime = DateFormat.jm().format(messageItem.time);
    } else if (timeDiff == -1) {
      messageTime = 'Yesterday ${DateFormat.jm().format(messageItem.time)}';
    } else {
      messageTime = DateFormat.yMMMd().add_jm().format(messageItem.time);
    }

    //MAIN SECTION

    // log('message name are for ${messageItem.message} ${messageItem.targetUsername}');

    return Row(
      mainAxisAlignment:
          messageItem.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        //message
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: messageItem.type.toLowerCase() == 'text'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Dismissible(
                      key: ValueKey(messageItem.messageId),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          await showBottom(context);
                        } else if (direction == DismissDirection.startToEnd) {
                          context.read<ReplyingMessageCubit>().reply(
                                isReplying: true,
                                isMine: messageItem.isMe,
                                message: messageItem.message,
                                type: messageItem.type,
                                name: messageItem.targetUsername,
                              );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          //reply
                          if (messageItem.isReplied)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                right: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  messageItem.isRepliedToMyself
                                      ? Text(
                                          'You replied to yourself',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Colors.black.withOpacity(.5)
                                              // color: messageItem.isMe
                                              //     ? Colors.white.withOpacity(.8)
                                              //     : Colors.black.withOpacity(.7),
                                              ),
                                        )
                                      : Text(
                                          'You replied to ${messageItem.targetUsername}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black.withOpacity(.5),
                                          ),
                                        ),

                                  //message
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: screen.width * .8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: messageItem.isRepliedToMyself
                                          ? appColors.primaryColor
                                              .withOpacity(.8)
                                          : Colors.grey[200],
                                      borderRadius: messageItem
                                              .isRepliedToMyself
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              // bottomRight: Radius.circular(10),
                                            )
                                          : const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              // bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                    ),
                                    child: messageItem.repliedToMessage.contains(
                                            'https://firebasestorage.googleapis.com/')
                                        ? SizedBox(
                                            height: 80,
                                            width: 80,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl: messageItem
                                                    .repliedToMessage,
                                                // width: MediaQuery.of(context)
                                                //     .size
                                                //     .width,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    CupertinoActivityIndicator(
                                                  radius: 8,
                                                  color: appColors.primaryColor,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  color: appColors.redColor,
                                                ),
                                              ),
                                            ),
                                          )
                                        : messageItem.repliedToMessage.length >
                                                40
                                            ? Text(
                                                '${messageItem.repliedToMessage.substring(0, 38)}....',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: messageItem
                                                          .isRepliedToMyself
                                                      ? Colors.white
                                                          .withOpacity(.9)
                                                      : Colors.black
                                                          .withOpacity(.5),
                                                ),
                                              )
                                            : Text(
                                                messageItem.repliedToMessage,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: messageItem
                                                          .isRepliedToMyself
                                                      ? Colors.white
                                                          .withOpacity(.9)
                                                      : Colors.black
                                                          .withOpacity(.5),
                                                ),
                                              ),
                                  ),
                                ],
                              ),
                            ),

                          //message
                          Container(
                            constraints:
                                BoxConstraints(maxWidth: screen.width * .8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: messageItem.isMe
                                  ? appColors.primaryColor
                                  : Colors.grey[300],
                              borderRadius: messageItem.isMe
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      // bottomRight: Radius.circular(10),
                                    )
                                  : const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      // bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messageItem.message,
                                  style: TextStyle(
                                    color: messageItem.isMe
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: EmojiUtil.hasOnlyEmojis(
                                            messageItem.message)
                                        ? 20
                                        : 14,
                                    // fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  messageTime,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: messageItem.isMe
                                        ? Colors.white.withOpacity(.8)
                                        : Colors.black.withOpacity(.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //read status
                    if (messageItem.isMe && messageItem.read)
                      const Text(
                        'read',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                )

              //image message preview
              : Dismissible(
                  key: ValueKey(messageItem.messageId),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      await showBottom(context);
                    } else if (direction == DismissDirection.startToEnd) {
                      context.read<ReplyingMessageCubit>().reply(
                            isReplying: true,
                            isMine: messageItem.isMe,
                            type: messageItem.type,
                            message: messageItem.message,
                            name: messageItem.targetUsername,
                          );
                    }
                    return null;
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //message
                      Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: messageItem.isMe
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  // bottomRight: Radius.circular(10),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  // bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                          color: messageItem.isMe
                              ? appColors.primaryColor
                              : Colors.grey.withOpacity(.2),
                          border: Border.all(
                            width: 6,
                            color: messageItem.isMe
                                ? appColors.primaryColor
                                : Colors.grey.withOpacity(0),
                          ),
                        ),
                        child: messageItem.message == ''
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: messageItem.isMe
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                          // bottomRight: Radius.circular(5),
                                        )
                                      : const BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                          // bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        ),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: appColors.primaryColor,
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'sending',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ImageMessagePreview(
                                          url: messageItem.message,
                                          id: messageItem.messageId),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    //image
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: messageItem.isMe
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(5),
                                                bottomLeft: Radius.circular(5),
                                                // bottomRight: Radius.circular(5),
                                              )
                                            : const BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(5),
                                                // bottomLeft: Radius.circular(5),
                                                bottomRight: Radius.circular(5),
                                              ),
                                        child: Container(
                                          color: Colors.white,
                                          child: CachedNetworkImage(
                                            imageUrl: messageItem.message,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              color: messageItem.isMe
                                                  ? appColors.primaryColor
                                                  : Colors.black,
                                              radius: 15,
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              color: appColors.redColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    //time
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                        messageTime,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: messageItem.isMe
                                              ? Colors.white.withOpacity(.8)
                                              : Colors.black.withOpacity(.5),
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      //read
                      if (messageItem.isMe && messageItem.read)
                        const Text(
                          'seen',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  //bottom sheet
  Future<void> showBottom(BuildContext ctx) async {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();
    await showModalBottomSheet<void>(
      context: ctx,
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
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: messageItem.type.toLowerCase() == 'image'
                    ? const Text(
                        'Image',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : messageItem.message.length > 30
                        ? Text(
                            '"${messageItem.message.substring(0, 28)}..."',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            '"${messageItem.message}"',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
              if (messageItem.isMe)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      firebaseOperations.deleteMessageForAll(
                          messageId: messageItem.messageId,
                          type: messageItem.type,
                          senderId: messageItem.currentUserid,
                          targetId: messageItem.targetUserid);
                      Navigator.of(ctx).pop(true);
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      // height: 50,
                      width: double.infinity,
                      child: Text(
                        "Delete for all",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: appColors.redColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    firebaseOperations.deleteMessageForMe(
                      messageId: messageItem.messageId,
                      senderId: messageItem.currentUserid,
                      type: messageItem.type,
                      targetId: messageItem.targetUserid,
                      message: 'Message deleted for you',
                    );
                    Navigator.of(ctx).pop(true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    width: double.infinity,
                    child: Text(
                      "Delete for me",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.redColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              //cancel button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    width: double.infinity,
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.primaryColor),
                      textAlign: TextAlign.center,
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
