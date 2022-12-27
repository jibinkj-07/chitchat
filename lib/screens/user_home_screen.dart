import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/screens/find_friends_screen.dart';
import 'package:chitchat/screens/profile_screen.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/database/hive_operations.dart';
import 'chat_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final int index;
  final String userid;
  const UserHomeScreen({
    super.key,
    required this.index,
    required this.userid,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with WidgetsBindingObserver {
  late int currentIndex;
  FirebaseOperations firebaseOperations = FirebaseOperations();

  @override
  void initState() {
    currentIndex = widget.index;
    WidgetsBinding.instance.addObserver(this);
    firebaseOperations.changeStatus(userId: widget.userid, status: 'online');
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      firebaseOperations.changeStatus(userId: widget.userid, status: 'away');
    } else if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      firebaseOperations.changeStatus(userId: widget.userid, status: 'offline');
    } else if (state == AppLifecycleState.resumed) {
      firebaseOperations.changeStatus(userId: widget.userid, status: 'online');
    }
    super.didChangeAppLifecycleState(state);
  }

  //list of pages
  final List<Map<String, dynamic>> pages = [
    {
      'page': const ChatScreen(),
      'title': 'Chat',
      // 'action':[FlatButton(onPressed: onPressed, child: child)]
    },
    {
      'page': const FindFriendsScreen(),
      'title': 'Find Friends',
      // 'action':[FlatButton(onPressed: onPressed, child: child)]
    },
    {
      'page': const ProfileScreen(),
      'title': 'Settings',
      // 'action':[FlatButton(onPressed: onPressed, child: child)]
    },
  ];

//main
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    //calling hive method to get user detail
    getUserDetailHive();
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: SafeArea(
              child: pages[currentIndex]['page'],
            ),
            bottomNavigationBar: CustomNavigationBar(
              backgroundColor: Colors.white,
              iconSize: 28.0,
              selectedColor: appColors.primaryColor,
              strokeColor: appColors.primaryColor,
              items: [
                CustomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.bubble_left_bubble_right),
                  selectedIcon:
                      const Icon(CupertinoIcons.bubble_left_bubble_right_fill),
                  showBadge:
                      snapshot.data!.get('chat_count') == 0 ? false : true,
                  title: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack.withOpacity(.6),
                    ),
                  ),
                  selectedTitle: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.primaryColor,
                    ),
                  ),
                  badgeCount: snapshot.data!.get('chat_count'),
                ),
                CustomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.person_2_square_stack),
                  selectedIcon:
                      const Icon(CupertinoIcons.person_2_square_stack_fill),
                  title: Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack.withOpacity(.6),
                    ),
                  ),
                  selectedTitle: Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.primaryColor,
                    ),
                  ),
                ),
                CustomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.person),
                  selectedIcon: const Icon(CupertinoIcons.person_fill),
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack.withOpacity(.6),
                    ),
                  ),
                  selectedTitle: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
              currentIndex: currentIndex,
              onTap: (index) {
                setState(
                  () {
                    currentIndex = index;
                  },
                );
              },
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: appColors.primaryColor,
              strokeWidth: 2.0,
            ),
          ),
        );
      },
    );
  }
}
