import 'dart:developer';

import 'package:chitchat/logic/database/firebase_chat_operations.dart';
import 'package:chitchat/screens/home_screen.dart';
import 'package:chitchat/widgets/chat/chat_body.dart';
import 'package:chitchat/widgets/chat/chat_user_detail_screen.dart';
import 'package:chitchat/widgets/general/image_previewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/app_colors.dart';

class SingleChatScreen extends StatefulWidget {
  final String targetUserid;
  final String currentUserid;
  const SingleChatScreen({
    super.key,
    required this.targetUserid,
    required this.currentUserid,
  });

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.targetUserid)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                final name = snapshot.data!.get('name');
                final status = snapshot.data!.get('status');
                final url = snapshot.data!.get('imageUrl');
                final isVerified = snapshot.data!.get('verified');
                return Column(
                  children: [
                    Material(
                      color: appColors.textColorWhite,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 0),
                        //user detail top
                        child: chatTopBar(
                          context: context,
                          currentUserid: widget.currentUserid,
                          targetUserid: widget.targetUserid,
                          name: name,
                          status: status,
                          url: url,
                          appColors: appColors,
                          isVerified: isVerified,
                        ),
                      ),
                    ),
                    Divider(
                      height: 0,
                      color: appColors.textColorBlack.withOpacity(.5),
                      thickness: .5,
                    ),

                    //chat body
                    NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: Expanded(
                        child: ChatBody(
                          currentUserid: widget.currentUserid,
                          targetUserid: widget.targetUserid,
                          targetName: name,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),
      ),
    );
  }

//showing dialog box for clearing chat
  clearChatDialogBox({
    required BuildContext context,
    required String senderId,
    required String targetId,
  }) {
    FocusScope.of(context).unfocus();
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

  Widget chatTopBar(
          {required BuildContext context,
          required String targetUserid,
          required String currentUserid,
          required name,
          required status,
          required url,
          required isVerified,
          required AppColors appColors}) =>
      Row(
        //back arrow
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(index: 0),
                  ),
                  (route) => false);
            },
            color: appColors.textColorBlack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            iconSize: 20.0,
            splashRadius: 20.0,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => ChatUserDetailScreen(
                        currentUserid: currentUserid,
                        targetUserid: targetUserid,
                      ),
                    ),
                    (route) => false);
              },
              child: Row(
                children: [
                  //image
                  ImagePreviewer(
                      targetUserid: targetUserid,
                      width: 40,
                      height: 40,
                      url: url),
                  const SizedBox(width: 5),
                  //name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            name.toString().length > 20
                                ? Text(
                                    '${name.toString().substring(0, 18)}...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: appColors.textColorBlack,
                                    ),
                                  )
                                : Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: appColors.textColorBlack,
                                    ),
                                  ),
                            if (isVerified)
                              Icon(
                                Iconsax.verify5,
                                color: appColors.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                        Text(
                          status,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: status == 'online'
                                ? appColors.greenColor
                                : status == 'away'
                                    ? Colors.orange
                                    : appColors.textColorBlack.withOpacity(.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //clear chat button
          IconButton(
            onPressed: () {
              clearChatDialogBox(
                context: context,
                senderId: currentUserid,
                targetId: targetUserid,
              );
            },
            icon: const Icon(Iconsax.broom),
            splashRadius: 20.0,
            color: appColors.textColorBlack,
          ),
        ],
      );
}
