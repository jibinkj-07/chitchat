import 'dart:developer';

import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/single_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../logic/database/firebase_chat_operations.dart';
import '../general/image_preview.dart';
import '../general/image_previewer.dart';

class ChatUserDetailScreen extends StatelessWidget {
  final String targetUserid;
  final String currentUserid;
  const ChatUserDetailScreen({
    super.key,
    required this.currentUserid,
    required this.targetUserid,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => SingleChatScreen(
                currentUserid: currentUserid,
                targetUserid: targetUserid,
              ),
            ),
            (route) => false);
        return true;
      },
      child: Scaffold(
        backgroundColor: appColors.textColorWhite.withAlpha(240),
        body: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(targetUserid)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                final name = snapshot.data!.get('name');
                final status = snapshot.data!.get('status');
                final url = snapshot.data!.get('imageUrl');
                final isVerified = snapshot.data!.get('verified');
                final joined = snapshot.data!.get('created').toDate();
                final bio = snapshot.data!.get('bio');
                final username = snapshot.data!.get('username');

                return SizedBox(
                  width: screen.width,
                  height: screen.height,
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screen.width,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 15.0),
                            decoration: BoxDecoration(
                              color: appColors.textColorWhite,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                topBar(context: context, screen: screen),
                                userDetails(
                                  context: context,
                                  id: targetUserid,
                                  appColors: appColors,
                                  screen: screen,
                                  isVerified: isVerified,
                                  name: name,
                                  status: status,
                                  url: url,
                                  username: username,
                                ),
                                moreButton(),
                              ],
                            ),
                          ),
                          userBio(
                            appColors: appColors,
                            screen: screen,
                            bio: bio,
                          ),
                          joinedInfo(
                            appColors: appColors,
                            screen: screen,
                            joined: joined,
                          ),
                          buttons(
                              appColors: appColors,
                              screen: screen,
                              context: context)
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget topBar({
    required BuildContext context,
    required Size screen,
  }) {
    return IconButton(
      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => SingleChatScreen(
              currentUserid: currentUserid,
              targetUserid: targetUserid,
            ),
          ),
          (route) => false),
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      iconSize: 20.0,
      splashRadius: 20.0,
    );
  }

  Widget userDetails({
    required BuildContext context,
    required String id,
    required Size screen,
    required AppColors appColors,
    required String status,
    required String url,
    required bool isVerified,
    required String name,
    required String username,
  }) {
    final statusColor = status == 'online'
        ? appColors.greenColor
        : status == 'away'
            ? appColors.yellowColor
            : appColors.textColorBlack;
    return SizedBox(
      // width: screen.width,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ImagePreview(
                  id: id,
                  url: url,
                  title: 'Profile Photo',
                  isEditable: false,
                ),
              ),
            ),
            child: ImagePreviewer(
              targetUserid: targetUserid,
              width: 120,
              height: 120,
              url: url,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            username,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (isVerified)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.verify5,
                  size: 15,
                  color: appColors.primaryColor,
                ),
                const SizedBox(width: 2),
                Text(
                  'Verified Account',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: appColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          const SizedBox(height: 5.0),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget moreButton() {
    return const IconButton(
      onPressed: null,
      icon: Icon(Icons.more),
      disabledColor: Colors.white,
    );
  }

  userBio({
    required AppColors appColors,
    required Size screen,
    required String bio,
  }) {
    return Container(
      width: screen.width,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: appColors.textColorWhite,
      ),
      child: Text(
        bio,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget joinedInfo({
    required AppColors appColors,
    required Size screen,
    required DateTime joined,
  }) {
    return Container(
      width: screen.width,
      margin: const EdgeInsets.only(bottom: 30.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: appColors.textColorWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Joined chitchat on',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: appColors.textColorBlack.withOpacity(.5),
            ),
          ),
          Text(
            DateFormat.yMMMMEEEEd().format(joined),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buttons(
      {required AppColors appColors,
      required Size screen,
      required BuildContext context}) {
    return Container(
      color: appColors.textColorWhite,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          //chat clear
          Material(
            color: appColors.textColorWhite,
            child: InkWell(
              onTap: () => clearChatDialogBox(
                context: context,
                senderId: currentUserid,
                targetId: targetUserid,
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.broom,
                      size: 20,
                      color: appColors.textColorBlack.withOpacity(.8),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Clear chat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    //arrow icon
                  ],
                ),
              ),
            ),
          ),

          //delete contact
          Material(
            color: appColors.textColorWhite,
            child: InkWell(
              onTap: () {
                deleteAccountDialogBox(
                  context: context,
                  senderId: currentUserid,
                  targetId: targetUserid,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.user_minus,
                      size: 20,
                      color: appColors.redColor,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Delete contact',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: appColors.redColor),
                    ),
                    //arrow icon
                  ],
                ),
              ),
            ),
          ),

          //block
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUserid)
                .collection('messages')
                .doc(targetUserid)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                bool isReported = false;
                bool isReportedByMe = true;
                try {
                  isReported = snapshot.data!.get('isReported');
                  isReportedByMe = snapshot.data!.get('isReportedByMe');
                } catch (e) {
                  log('error in ${e.toString()}');
                }
                return isReported
                    ? isReportedByMe
                        ? Material(
                            color: appColors.textColorWhite,
                            child: InkWell(
                              onTap: () {
                                FirebaseOperations().unBlockAccount(
                                  targetUserid: targetUserid,
                                  currentUserid: currentUserid,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Iconsax.slash,
                                      size: 20,
                                      color: appColors.textColorBlack
                                          .withOpacity(.8),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Unblock',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: appColors.textColorBlack,
                                      ),
                                    ),
                                    //arrow icon
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox()
                    : Material(
                        color: appColors.textColorWhite,
                        child: InkWell(
                          onTap: () {
                            reportAccountDialogBox(
                              context: context,
                              senderId: currentUserid,
                              targetId: targetUserid,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Iconsax.slash,
                                  size: 20,
                                  color: appColors.redColor,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  'Report and block',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: appColors.redColor,
                                  ),
                                ),
                                //arrow icon
                              ],
                            ),
                          ),
                        ),
                      );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  //showing dialog box for clearing chat
  clearChatDialogBox({
    required BuildContext context,
    required String senderId,
    required String targetId,
  }) {
    AppColors appColors = AppColors();
    FirebaseChatOperations firebaseChatOperations = FirebaseChatOperations();

    showProgress(BuildContext context1) {
      showDialog(
        context: context1,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appColors.redColor,
                    // backgroundColor: appColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                const Text(
                  'Clearing messages',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return
            //clearing chat history dialog box
            AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          title: const Text(
            "Clear chat history",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          content: const Text(
            "Clearing chat will delete all your messages permanently.",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //for all button
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    nav.pop(true);
                    showProgress(ctx);
                    await firebaseChatOperations.clearChatForAll(
                        senderId: senderId,
                        targetId: targetId,
                        message: 'Chat history cleared for all');
                    nav.pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.redColor,
                  ),
                  child: const Text("Clear for all"),
                ),
                //for me button
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    nav.pop(true);
                    showProgress(ctx);
                    await firebaseChatOperations.clearChatForMe(
                        senderId: senderId,
                        targetId: targetId,
                        message: 'Chat history cleared for me only');
                    nav.pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.redColor,
                  ),
                  child: const Text("Clear for me"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  //showing dialog box for deleting account
  deleteAccountDialogBox({
    required BuildContext context,
    required String senderId,
    required String targetId,
  }) {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();

    showProgress(BuildContext context1) {
      showDialog(
        context: context1,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appColors.redColor,
                    // backgroundColor: appColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                const Text(
                  'Deleting account',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return
            //clearing chat history dialog box
            AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          title: const Text(
            "Delete Account",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          content: const Text(
            "Deleting account will remove all your conversations including images,voices permanently.",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //for all button
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    nav.pop(true);
                    showProgress(ctx);
                    await firebaseOperations.deleteContact(
                      context: context,
                      currentUserid: currentUserid,
                      targetUserid: targetUserid,
                      forAll: true,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.redColor,
                  ),
                  child: const Text("Delete for both"),
                ),
                //for me button
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    nav.pop(true);
                    showProgress(ctx);
                    await firebaseOperations.deleteContact(
                      context: context,
                      currentUserid: currentUserid,
                      targetUserid: targetUserid,
                      forAll: false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.redColor,
                  ),
                  child: const Text("Delete for me"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  //showing dialog box for deleting account
  reportAccountDialogBox({
    required BuildContext context,
    required String senderId,
    required String targetId,
  }) {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return
            //clearing chat history dialog box
            AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          title: const Text(
            "Report and Block",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          content: const Text(
            "Are you sure you want to report this account?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //for all button
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.textColorBlack,
                  ),
                  child: const Text("Cancel"),
                ),
                //for me button
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(ctx);
                    await firebaseOperations.reportAccount(
                      targetUserid: targetUserid,
                      currentUserid: currentUserid,
                    );
                    nav.pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.redColor,
                  ),
                  child: const Text("Report and Block"),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
