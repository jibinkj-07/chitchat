import 'dart:developer';
import 'package:chitchat/logic/notification_services.dart';
import 'package:chitchat/screens/user_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final int index;
  const HomeScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final userid = FirebaseAuth.instance.currentUser!.uid;
    NotificationService notificationService = NotificationService();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userid)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //notification part
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isNotEmpty) {
            final chats = snapshot.data!.docs;
            for (int i = 0; i < chats.length; i++) {
              final id = chats[i].id;
              final isNew = chats[i].get('isNew');
              final msg = chats[i].get('last_message');
              final isNotified = chats[i].get('isNotified');

              if (isNew && !isNotified) {
                final name = chats[i].get('senderName');
                log('notification for $msg for $i');
                notificationService.showNotification(
                  id: i + 1,
                  message: msg,
                  user: name,
                );
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userid)
                    .collection('messages')
                    .doc(id)
                    .set(
                  {'isNotified': true},
                  SetOptions(merge: true),
                );
              }
            }
          }
        }

        //main section
        return UserHomeScreen(index: index, userid: userid);
      },
    );
  }
}
