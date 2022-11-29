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

class MessageBubble extends StatelessWidget {
  final String messageId;
  final String message;
  final String currentUserid;
  final String targetUserid;
  final bool isReplied;
  final String repliedToMessage;
  final bool read;
  final DateTime? readTime;
  final DateTime time;
  final String type;
  final bool isMe;
  const MessageBubble({
    super.key,
    required this.messageId,
    required this.message,
    required this.time,
    required this.isReplied,
    required this.type,
    required this.repliedToMessage,
    required this.currentUserid,
    required this.targetUserid,
    required this.isMe,
    required this.read,
    this.readTime,
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

    if (!isMe) {
      FirebaseOperations().changeReadMessageStatus(
        messageId: messageId,
        senderId: currentUserid,
        targetId: targetUserid,
      );
    }
    final timeDiff = calculateDifference(time);
    String messageTime = '';
    if (timeDiff == 0) {
      messageTime = DateFormat.jm().format(time);
    } else if (timeDiff == -1) {
      messageTime = 'Yesterday ${DateFormat.jm().format(time)}';
    } else {
      messageTime = DateFormat.yMMMd().add_jm().format(time);
    }

    //MAIN SECTION

    // log('$message contains emoji only ${EmojiUtil.hasOnlyEmojis(message)}');

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        //message
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: type.toLowerCase() == 'text'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Dismissible(
                      key: ValueKey(messageId),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          await showBottom(context);
                        } else if (direction == DismissDirection.startToEnd) {
                          context.read<ReplyingMessageCubit>().reply(
                              isReplying: true, isMine: isMe, message: message);
                        }
                      },
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: screen.width * .8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              isMe ? appColors.primaryColor : Colors.grey[300],
                          borderRadius: isMe
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
                            if (isReplied)
                              Text(
                                'Replied to "$repliedToMessage"',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isMe
                                      ? Colors.white.withOpacity(.8)
                                      : Colors.black.withOpacity(.7),
                                ),
                              ),
                            Text(
                              message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize:
                                    EmojiUtil.hasOnlyEmojis(message) ? 20 : 14,
                                // fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              messageTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white.withOpacity(.8)
                                    : Colors.black.withOpacity(.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //read status
                    if (isMe && read)
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
                  key: ValueKey(messageId),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      await showBottom(context);
                    } else if (direction == DismissDirection.startToEnd) {
                      context.read<ReplyingMessageCubit>().reply(
                          isReplying: true, isMine: isMe, message: 'Image');
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //message
                      Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: isMe
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
                          color: isMe
                              ? appColors.primaryColor
                              : Colors.grey.withOpacity(.2),
                          border: Border.all(
                            width: 6,
                            color: isMe
                                ? appColors.primaryColor
                                : Colors.grey.withOpacity(0),
                          ),
                        ),
                        child: message == ''
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: isMe
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
                                  children: const [
                                    CupertinoActivityIndicator(
                                      radius: 10,
                                    ),
                                    Text(
                                      'sending image',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ImageMessagePreview(
                                          url: message, id: messageId),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    //image
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: isMe
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
                                            imageUrl: message,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              color: isMe
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
                                          color: isMe
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
                      if (isMe && read)
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
                child: type.toLowerCase() == 'image'
                    ? const Text(
                        'Image',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : message.length > 30
                        ? Text(
                            '"${message.substring(0, 28)}..."',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            '"$message"',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
              if (isMe)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      firebaseOperations.deleteMessageForAll(
                          messageId: messageId,
                          type: type,
                          senderId: currentUserid,
                          targetId: targetUserid);
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
                      messageId: messageId,
                      senderId: currentUserid,
                      type: type,
                      targetId: targetUserid,
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
