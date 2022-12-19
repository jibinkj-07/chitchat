import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/chat_functions.dart';
import 'package:chitchat/widgets/chat/all_chat_search.dart';
import 'package:chitchat/widgets/chat/chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isFabExtended = false;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    AppColors appColors = AppColors();
    final currentUserid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopTitle(
              screen: screen,
              appColors: appColors,
              currentUserid: currentUserid,
            ),
            Divider(
              height: 0,
              color: appColors.textColorBlack.withOpacity(.3),
            ),

            //chat list
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse) {
                    if (!isFabExtended) {
                      setState(() {
                        isFabExtended = true;
                      });
                    }
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    if (isFabExtended) {
                      setState(() {
                        isFabExtended = false;
                      });
                    }
                  }
                  return true;
                },
                child: Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(currentUserid)
                        .collection('messages')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (ctx, i) {
                              final lstMsg = snapshot.data!.docs[i]
                                  .get('last_message')
                                  .toString();
                              final isNew = snapshot.data!.docs[i].get('isNew');
                              final timeFromDb =
                                  snapshot.data!.docs[i].get('time').toDate();
                              final unreadCount =
                                  snapshot.data!.docs[i].get('unread_count');
                              final time = ChatFuntions(time: timeFromDb)
                                  .formattedTime();
                              return ChatListItem(
                                screen: screen,
                                currentUserid: currentUserid,
                                isNew: isNew,
                                lastMessage: lstMsg,
                                targetUserid: snapshot.data!.docs[i].id,
                                time: time,
                                unreadCount: unreadCount,
                              );
                            },
                          );
                        }
                        return emptyChatList(context, appColors);
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isFabExtended
          ? buildFAB(context, appColors)
          : buildExtendedFAB(context, appColors),
    );
  }
}

Widget emptyChatList(BuildContext context, AppColors appColors) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.messages_35,
          color: appColors.textColorBlack.withOpacity(.8),
        ),
        const SizedBox(width: 5),
        Text(
          'Start chitchatting with friends',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appColors.textColorBlack.withOpacity(.8),
          ),
        ),
      ],
    );

class TopTitle extends StatelessWidget {
  const TopTitle({
    Key? key,
    required this.screen,
    required this.appColors,
    required this.currentUserid,
  }) : super(key: key);

  final Size screen;
  final AppColors appColors;
  final String currentUserid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screen.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10,
      ),

      // height: 80,
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
                    radius: 6.0,
                    backgroundColor: appColors.greenColor,
                  ),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Searching for network",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: appColors.textColorBlack.withOpacity(.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: appColors.textColorBlack.withOpacity(.7),
                        strokeWidth: 1.5,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Chats",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: appColors.textColorBlack,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AllChatSearch(
                      currentUserid: currentUserid,
                    ),
                  ),
                ),
                icon: const Icon(
                  Iconsax.search_normal_1,
                ),
                color: appColors.textColorBlack,
                splashRadius: 20.0,
              )
            ],
          ),
        ],
      ),
    );
  }
}

//floating button
Widget buildFAB(BuildContext context, AppColors appColors) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
      width: 50,
      height: 50,
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: appColors.primaryColor,
        child: const Icon(
          Iconsax.add,
          color: Colors.white,
          size: 30,
        ),
        // label: const SizedBox(),
      ),
    );

Widget buildExtendedFAB(BuildContext context, AppColors appColors) =>
    AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 100,
      height: 50,
      child: FloatingActionButton.extended(
        backgroundColor: appColors.primaryColor,
        onPressed: () {},
        icon: const Icon(
          Iconsax.add,
          size: 25,
          color: Colors.white,
        ),
        label: const Center(
          child: Text(
            "Chat",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
