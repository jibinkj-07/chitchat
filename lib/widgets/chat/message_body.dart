import 'dart:developer';

import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class MessageBody extends StatelessWidget {
  final String currentUserid;
  final String targetUserid;
  const MessageBody({
    super.key,
    required this.currentUserid,
    required this.targetUserid,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Container(
      width: screen.width,
      decoration: BoxDecoration(color: Colors.white),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserid)
            .collection('messages')
            .doc(targetUserid)
            .collection('chats')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (snapshot.hasData) {
            log('length is ${snapshot.data!.docs.length}');
            if (snapshot.data!.docs.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/illustrations/add_chat.svg',
                    width: 300,
                  ),
                  Text(
                    "Say Hello!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors().primaryColor,
                    ),
                  )
                ],
              );
            }
            //changing newMessage read status
            FirebaseOperations().changeNewMessageStatus(
              senderId: currentUserid,
              targetId: targetUserid,
            );

            // log('has data');
            //changing single message read status

            return ListView.builder(
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  final message = snapshot.data!.docs[i].get('body');
                  final time = snapshot.data!.docs[i].get('time').toDate();
                  final isMe = snapshot.data!.docs[i].get('sentByMe');
                  final read = snapshot.data!.docs[i].get('read');
                  final isReplied =
                      snapshot.data!.docs[i].get('isReplyingMessage');
                  final repliedToMessage =
                      snapshot.data!.docs[i].get('repliedTo');
                  DateTime? readTime;
                  try {
                    readTime = snapshot.data!.docs[i].get('readTime').toDate();
                  } catch (e) {
                    // log(e.toString());
                  }

                  return MessageBubble(
                    messageId: snapshot.data!.docs[i].id,
                    message: message,
                    isReplied: isReplied,
                    repliedToMessage: repliedToMessage,
                    currentUserid: currentUserid,
                    targetUserid: targetUserid,
                    time: time,
                    isMe: isMe,
                    read: read,
                    readTime: readTime,
                  );
                });
          }
          return const SizedBox();
        },
      ),
    );
  }
}
