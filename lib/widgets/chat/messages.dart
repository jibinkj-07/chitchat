import 'dart:developer';

import 'package:chitchat/logic/database/firebase_chat_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/chat_functions.dart';
import 'package:chitchat/widgets/chat/chat%20bubbles/received_chat_bubble.dart';
import 'package:chitchat/widgets/chat/chat%20bubbles/sender_chat_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../logic/cubit/replying_message_cubit.dart';
import '../../utils/message_Item.dart';

class Messages extends StatelessWidget {
  final MessageItem messageItem;
  Messages({
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
                type: messageItem.type,
                name: messageItem.targetUsername,
              );
        }
        return null;
      },
      child: messageItem.isMe
          ? SenderChatBubble(
              messageItem: messageItem,
              messageTime: messageTime,
            )
          : ReceivedMessageBubble(
              messageItem: messageItem, messageTime: messageTime),
    );
    // return Row(
    //   mainAxisAlignment:
    //       messageItem.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
    //   children: [
    //     Container(
    //       margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    //       child: Column(
    //         children: [
    //           Dismissible(
    //             key: ValueKey(messageItem.messageId),
    //             direction: DismissDirection.startToEnd,
    //             confirmDismiss: (direction) async {
    //               // if (direction == DismissDirection.endToStart) {
    //               //   await showBottom(context);
    //               // }

    //               if (direction == DismissDirection.startToEnd) {
    //                 context.read<ReplyingMessageCubit>().reply(
    //                       isReplying: true,
    //                       isMine: messageItem.isMe,
    //                       message: messageItem.message,
    //                       type: messageItem.type,
    //                       name: messageItem.targetUsername,
    //                     );
    //               }
    //               return null;
    //             },
    //             child: messageItem.type.toLowerCase() == 'text'
    //                 ? TextMessage(
    //                     screen: screen,
    //                     messageItem: messageItem,
    //                     appColors: appColors,
    //                     messageTime: messageTime,
    //                   )
    //                 : ImageMessage(
    //                     messageItem: messageItem,
    //                     appColors: appColors,
    //                     messageTime: messageTime,
    //                   ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}

// class ImageMessage extends StatelessWidget {
//   const ImageMessage({
//     Key? key,
//     required this.messageItem,
//     required this.appColors,
//     required this.messageTime,
//   }) : super(key: key);

//   final MessageItem messageItem;
//   final AppColors appColors;
//   final String messageTime;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         //message
//         Container(
//           height: 250,
//           width: 250,
//           decoration: BoxDecoration(
//             borderRadius: messageItem.isMe
//                 ? const BorderRadius.only(
//                     topLeft: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                     bottomLeft: Radius.circular(10),
//                     // bottomRight: Radius.circular(10),
//                   )
//                 : const BorderRadius.only(
//                     topLeft: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                     // bottomLeft: Radius.circular(10),
//                     bottomRight: Radius.circular(10),
//                   ),
//             color: messageItem.isMe
//                 ? appColors.primaryColor
//                 : Colors.grey.withOpacity(.2),
//             border: Border.all(
//               width: 6,
//               color: messageItem.isMe
//                   ? appColors.primaryColor
//                   : Colors.grey.withOpacity(0),
//             ),
//           ),
//           child: messageItem.message == ''
//               ? Container(
//                   decoration: BoxDecoration(
//                     borderRadius: messageItem.isMe
//                         ? const BorderRadius.only(
//                             topLeft: Radius.circular(5),
//                             topRight: Radius.circular(5),
//                             bottomLeft: Radius.circular(5),
//                             // bottomRight: Radius.circular(5),
//                           )
//                         : const BorderRadius.only(
//                             topLeft: Radius.circular(5),
//                             topRight: Radius.circular(5),
//                             // bottomLeft: Radius.circular(5),
//                             bottomRight: Radius.circular(5),
//                           ),
//                     color: Colors.white,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         strokeWidth: 1.5,
//                         color: appColors.primaryColor,
//                       ),
//                       const SizedBox(height: 5),
//                       const Text(
//                         'sending',
//                         style: TextStyle(
//                             fontSize: 12, fontWeight: FontWeight.w500),
//                       )
//                     ],
//                   ),
//                 )
//               : GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) => ImageMessagePreview(
//                             url: messageItem.message,
//                             id: messageItem.messageId),
//                       ),
//                     );
//                   },
//                   child: Column(
//                     children: [
//                       //image
//                       Expanded(
//                         child: ClipRRect(
//                           borderRadius: messageItem.isMe
//                               ? const BorderRadius.only(
//                                   topLeft: Radius.circular(5),
//                                   topRight: Radius.circular(5),
//                                   bottomLeft: Radius.circular(5),
//                                   // bottomRight: Radius.circular(5),
//                                 )
//                               : const BorderRadius.only(
//                                   topLeft: Radius.circular(5),
//                                   topRight: Radius.circular(5),
//                                   // bottomLeft: Radius.circular(5),
//                                   bottomRight: Radius.circular(5),
//                                 ),
//                           child: Container(
//                             color: Colors.white,
//                             child: CachedNetworkImage(
//                               imageUrl: messageItem.message,
//                               width: MediaQuery.of(context).size.width,
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) =>
//                                   CupertinoActivityIndicator(
//                                 color: messageItem.isMe
//                                     ? appColors.primaryColor
//                                     : Colors.black,
//                                 radius: 15,
//                               ),
//                               errorWidget: (context, url, error) => Icon(
//                                 Icons.error,
//                                 color: appColors.redColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       //time
//                       SizedBox(
//                         width: 250,
//                         child: Text(
//                           messageTime,
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: messageItem.isMe
//                                 ? Colors.white.withOpacity(.8)
//                                 : Colors.black.withOpacity(.5),
//                           ),
//                           textAlign: TextAlign.right,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//         ),
//         //reading status
//         if (messageItem.isMe && messageItem.read)
//           const Text(
//             'seen',
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//       ],
//     );
//   }
// }

// class TextMessage extends StatelessWidget {
  // const TextMessage({
  //   Key? key,
  //   required this.screen,
  //   required this.messageItem,
  //   required this.appColors,
  //   required this.messageTime,
  // }) : super(key: key);

  // final Size screen;
  // final MessageItem messageItem;
  // final AppColors appColors;
  // final String messageTime;

  // @override
  // Widget build(BuildContext context) {
  //   return SendMessageBubble(
  //     message: 'ji',
  //     messageTime: messageTime,
  //     read: messageItem.read,
  //   );
  // }
// }
