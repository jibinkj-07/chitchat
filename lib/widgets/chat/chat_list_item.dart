import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    Key? key,
    required this.screen,
    required this.targetUserid,
    required this.currentUserid,
    required this.lastMessage,
    required this.unreadCount,
    required this.isNew,
    required this.time,
  }) : super(key: key);

  final Size screen;
  final String targetUserid;
  final String currentUserid;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(targetUserid)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          final userDetail = snapshot.data;
        }
        return const SizedBox();
      },
    );
  }
}
