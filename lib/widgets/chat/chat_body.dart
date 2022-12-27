import 'dart:developer';

import 'package:chitchat/logic/database/firebase_chat_operations.dart';
import 'package:chitchat/widgets/chat/message_controls.dart';
import 'package:chitchat/widgets/chat/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/app_colors.dart';
import '../../utils/message_Item.dart';

class ChatBody extends StatefulWidget {
  final String currentUserid;
  final String targetUserid;
  final String targetName;
  final String senderName;
  const ChatBody({
    super.key,
    required this.currentUserid,
    required this.targetUserid,
    required this.targetName,
    required this.senderName,
  });

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
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
    AppColors appColors = AppColors();
    return Container(
      width: screen.width,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/pattern.png'),
          fit: BoxFit.cover,
        ),
        color: appColors.chatBgColor,
      ),
      child: Column(
        children: [
          Expanded(
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
                if (snapshot.hasData) {
                  // log('length is ${snapshot.data!.docs.length}');
                  if (snapshot.data!.docs.isEmpty) {
                    return emptyMessage(appColors: appColors);
                  } else {
                    // log('length is ${snapshot.data!.docs.length}');

                    //changing newMessage read status
                    FirebaseChatOperations().viewedChat(
                      senderId: widget.currentUserid,
                      targetId: widget.targetUserid,
                    );

                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(widget.currentUserid)
                        .collection('messages')
                        .doc(widget.targetUserid)
                        .get()
                        .then((value) {
                      if (value.get('isNew')) {
                        log('called decrement');
                        FirebaseChatOperations().decrementChatCount(
                            currentId: widget.currentUserid);
                      }
                    });

                    return messages(snapshot: snapshot);
                  }
                }
                return const SizedBox();
              },
            ),
          ),

          //chat controller box
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.currentUserid)
                .collection('messages')
                .doc(widget.targetUserid)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                bool isReported = false;
                try {
                  isReported = snapshot.data!.get('isReported');
                } catch (e) {
                  log('error in ${e.toString()}');
                }
                return isReported
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: appColors.textColorWhite,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.information,
                              size: 18,
                              color: appColors.redColor,
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              'You can\'t chat with reported users.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: appColors.redColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : MessageControls(
                        senderId: widget.currentUserid,
                        targetId: widget.targetUserid,
                        scrollController: scrollController,
                        sName: widget.senderName,
                        tName: widget.targetName,
                      );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget messages({required AsyncSnapshot<QuerySnapshot> snapshot}) =>
      NotificationListener<OverscrollIndicatorNotification>(
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
              DateTime? readTime;
              try {
                readTime = snapshot.data!.docs[i].get('readTime').toDate();
              } catch (e) {
                // log(e.toString());
              }

              final isMine = snapshot.data!.docs[i].get('sentByMe');
              final caption = snapshot.data!.docs[i].get('type') == 'image'
                  ? snapshot.data!.docs[i].get('caption')
                  : '';

              MessageItem messageItem = MessageItem(
                messageId: snapshot.data!.docs[i].id,
                message: snapshot.data!.docs[i].get('body'),
                time: snapshot.data!.docs[i].get('time').toDate(),
                isReplied: snapshot.data!.docs[i].get('isReplyingMessage'),
                replyingParentMessageType:
                    snapshot.data!.docs[i].get('replyingParentMessageType'),
                type: snapshot.data!.docs[i].get('type'),
                repliedToMessage: snapshot.data!.docs[i].get('repliedTo'),
                currentUserid: widget.currentUserid,
                caption: caption,
                targetUserid: widget.targetUserid,
                isRepliedToMyself: snapshot.data!.docs[i].get('repliedToMe'),
                isMe: isMine,
                read: snapshot.data!.docs[i].get('read'),
                readTime: readTime,
                targetUsername: widget.targetName,
              );

              return Messages(
                messageItem: messageItem,
              );
              // return SendMessageBubble(message: 'message');
            },
          ),
        ),
      );
}

Widget emptyMessage({required AppColors appColors}) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/illustrations/add_chat.svg',
          width: 200,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8.0),
          decoration: BoxDecoration(
            color: appColors.primaryColor.withOpacity(.8),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            "Say Hello!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: appColors.textColorWhite,
            ),
          ),
        )
      ],
    );
