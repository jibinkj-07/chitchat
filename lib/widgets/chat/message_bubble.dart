import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../logic/database/firebase_operations.dart';
import '../../utils/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String messageId;
  final String message;
  final String currentUserid;
  final String targetUserid;
  final bool read;
  final DateTime? readTime;
  final DateTime time;
  final bool isMe;
  const MessageBubble({
    super.key,
    required this.messageId,
    required this.message,
    required this.time,
    required this.currentUserid,
    required this.targetUserid,
    required this.isMe,
    required this.read,
    this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    AppColors appColors = AppColors();
    // final messageLength = message.length;

    if (!isMe) {
      FirebaseOperations().changeReadMessageStatus(
        messageId: messageId,
        senderId: currentUserid,
        targetId: targetUserid,
      );
    }

    //MAIN SECTION

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        //main
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Dismissible(
                key: ValueKey(messageId),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    await showBottom(context);
                  } else if (direction == DismissDirection.startToEnd) {
                    // replyMessage(
                    //   message: message,
                    //   isMine: isMe,
                    // );

                  }
                },
                child: Container(
                  // width: messageLength > 30 ? screen.width * .8 : null,
                  constraints: BoxConstraints(maxWidth: screen.width * .8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),

                  decoration: BoxDecoration(
                    color: isMe ? appColors.primaryColor : Colors.grey[300],
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat.jm().format(time),
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
                child: message.length > 30
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
                      targetId: targetUserid,
                      message: 'Deleted for you',
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
