import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ChatScreenBody(screen: screen, appColors: appColors),
        ),
      ),
    );
  }
}

class ChatScreenBody extends StatelessWidget {
  const ChatScreenBody({
    Key? key,
    required this.screen,
    required this.appColors,
  }) : super(key: key);

  final Size screen;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    final currentUserid = FirebaseAuth.instance.currentUser!.uid;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          width: screen.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BlocBuilder<InternetCubit, InternetState>(
                builder: (ctx, state) {
                  if (state is InternetEnabled) {
                    return CircleAvatar(
                      radius: 8.0,
                      backgroundColor: appColors.greenColor.withOpacity(.5),
                      child: CircleAvatar(
                        radius: 5.0,
                        backgroundColor: appColors.greenColor,
                      ),
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Searching for network",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 5),
                        CupertinoActivityIndicator(
                          color: Colors.black,
                          radius: 8.0,
                        ),
                      ],
                    );
                  }
                },
              ),
              const Text(
                "Chats",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // CupertinoSearchTextField(),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUserid)
                .collection('messages')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, i) {
                    final lstMsg =
                        snapshot.data!.docs[i].get('last_message').toString();
                    final isNew = snapshot.data!.docs[i].get('isNew');
                    final time = snapshot.data!.docs[i].get('time').toDate();
                    return ChatListItem(
                      userId: snapshot.data!.docs[i].id,
                      isNew: isNew,
                      lstMsg: lstMsg,
                      time: time,
                      currentUserid: currentUserid,
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        )
      ],
    );
  }
}
