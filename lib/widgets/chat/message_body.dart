import 'dart:developer';

import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:chitchat/widgets/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessageBody extends StatefulWidget {
  final String currentUserid;
  final String targetUserid;
  final String targetName;
  const MessageBody({
    super.key,
    required this.currentUserid,
    required this.targetUserid,
    required this.targetName,
  });

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController = ScrollController(initialScrollOffset: 0.0);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Container(
      width: screen.width,
      decoration: const BoxDecoration(color: Colors.white),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.currentUserid)
            .collection('messages')
            .doc(widget.targetUserid)
            .collection('chats')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: CupertinoActivityIndicator(),
          //   );
          // }

          if (snapshot.hasData) {
            // log('length is ${snapshot.data!.docs.length}');
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
            log('length is ${snapshot.data!.docs.length}');
            if (scrollController.hasClients) {
              scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
              );
            }

            //changing newMessage read status
            FirebaseOperations().changeNewMessageStatus(
              senderId: widget.currentUserid,
              targetId: widget.targetUserid,
            );

            // log('has data');
            //changing single message read status

            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: Scrollbar(
                thickness: 6.0,
                interactive: true,
                controller: scrollController,
                radius: const Radius.circular(30),
                child: ListView.builder(
                    reverse: true,
                    controller: scrollController,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (ctx, i) {
                      final message = snapshot.data!.docs[i].get('body');
                      final time = snapshot.data!.docs[i].get('time').toDate();
                      final isMe = snapshot.data!.docs[i].get('sentByMe');
                      final read = snapshot.data!.docs[i].get('read');
                      final isReplied =
                          snapshot.data!.docs[i].get('isReplyingMessage');
                      final isRepliedToMyself =
                          snapshot.data!.docs[i].get('repliedToMe');
                      final repliedToMessage =
                          snapshot.data!.docs[i].get('repliedTo');
                      final type = snapshot.data!.docs[i].get('type');
                      DateTime? readTime;
                      try {
                        readTime =
                            snapshot.data!.docs[i].get('readTime').toDate();
                      } catch (e) {
                        // log(e.toString());
                      }

                      MessageItem messageItem = MessageItem(
                        messageId: snapshot.data!.docs[i].id,
                        message: message,
                        time: time,
                        isReplied: isReplied,
                        type: type,
                        repliedToMessage: repliedToMessage,
                        currentUserid: widget.currentUserid,
                        targetUserid: widget.targetUserid,
                        isRepliedToMyself: isRepliedToMyself,
                        isMe: isMe,
                        read: read,
                        readTime: readTime,
                        targetUsername: widget.targetName,
                      );

                      return MessageBubble(messageItem: messageItem);
                    }),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
