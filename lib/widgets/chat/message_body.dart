import 'dart:developer';

import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
//changing newMessage read status
          FirebaseOperations().changeNewMessageStatus(
            senderId: currentUserid,
            targetId: targetUserid,
          );

          if (snapshot.hasData) {
            log('has data');
            //changing single message read status

            return ListView.builder(
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, i) {
                  final message = snapshot.data!.docs[i].get('body');
                  final time = snapshot.data!.docs[i].get('time').toDate();
                  final isMe = snapshot.data!.docs[i].get('sentByMe');
                  final read = snapshot.data!.docs[i].get('read');
                  DateTime? readTime;
                  try {
                    readTime = snapshot.data!.docs[i].get('readTime').toDate();
                  } catch (e) {
                    // log(e.toString());
                  }

                  return MessageBubble(
                    messageId: snapshot.data!.docs[i].id,
                    message: message,
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
