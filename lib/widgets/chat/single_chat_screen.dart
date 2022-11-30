import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/message_body.dart';
import 'package:chitchat/widgets/chat/message_controls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SingleChatScreen extends StatelessWidget {
  const SingleChatScreen({
    super.key,
    required this.currentUserid,
    required this.targetUserid,
  });
  final String currentUserid;
  final String targetUserid;

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(targetUserid)
              .snapshots(),
          builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.black,
                        splashRadius: 20.0,
                        iconSize: 20.0,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/homeScreen', (route) => false);
                        },
                      ),
                      snapshot.data!.get('imageUrl') == ''
                          ? Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: .5,
                                  color: Colors.grey,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data!.get('imageUrl'),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              color: appColors.primaryColor,
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: appColors.redColor,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              snapshot.data!.get('name').length > 20
                                  ? Text(
                                      '${snapshot.data!.get('name').substring(0, 18)}...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(
                                      snapshot.data!.get('name'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              if (snapshot.data!.get('verified'))
                                Icon(
                                  Iconsax.verify5,
                                  color: appColors.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                          Text(
                            snapshot.data!.get('status'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: snapshot.data!.get('status') == 'online'
                                  ? appColors.greenColor
                                  : snapshot.data!.get('status') == 'away'
                                      ? appColors.yellowColor
                                      : Colors.grey,
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              showBottom(context);
                            },
                            icon: const Icon(Iconsax.broom),
                            splashRadius: 20.0,
                          ),
                        ),
                      )
                    ],
                  ),

                  const Divider(height: 0),
                  //chat screen message body
                  Expanded(
                    child: MessageBody(
                      currentUserid: currentUserid,
                      targetUserid: targetUserid,
                      targetName: snapshot.data!.get('name'),
                    ),
                  ),

                  //chat screen message controller
                  // MessageControls(
                  //   senderId: currentUserid,
                  //   targetId: targetUserid,
                  // ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  //bottom sheet
  showBottom(BuildContext ctx) {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Clear chat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    firebaseOperations.clearChatForAll(
                        senderId: currentUserid,
                        targetId: targetUserid,
                        message: 'Cleared chat history for both');
                    Navigator.of(ctx).pop(true);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    // height: 50,
                    width: double.infinity,
                    child: Text(
                      "For both",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.redColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    firebaseOperations.clearChatForMe(
                        senderId: currentUserid,
                        targetId: targetUserid,
                        message: 'Cleared chat history for me');
                    Navigator.of(ctx).pop(true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    width: double.infinity,
                    child: Text(
                      "Only for me",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.redColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              //cancel button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    width: double.infinity,
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
