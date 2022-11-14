import 'package:chitchat/screens/all_users_screen.dart';
import 'package:chitchat/screens/chat_screen.dart';
import 'package:chitchat/screens/setting_screen.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  //list of pages
  final List<Map<String, dynamic>> pages = [
    {
      'page': const ChatScreen(),
      'title': 'Chat',
      // 'action':[FlatButton(onPressed: onPressed, child: child)]
    },
    {
      'page': AllUsersScreen(),
      'title': 'Find Friends',
      // 'action':[FlatButton(onPressed: onPressed, child: child)]
    },
    {
      'page': const SettingScreen(),
      'title': 'Settings',
      // 'action':[FlatButton(onPressed: onPressed, child: child)]
    },
  ];

//main
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
      body: SafeArea(
        child: pages[currentIndex]['page'],
      ),
      bottomNavigationBar: CustomNavigationBar(
        iconSize: 28.0,
        selectedColor: appColors.primaryColor,
        strokeColor: appColors.primaryColor,
        items: [
          CustomNavigationBarItem(
            icon: const Icon(CupertinoIcons.bubble_left_bubble_right),
            showBadge: true,
            badgeCount: 4,
          ),
          CustomNavigationBarItem(
            icon: const Icon(CupertinoIcons.rectangle_stack_person_crop),
          ),
          CustomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings_solid),
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
}
