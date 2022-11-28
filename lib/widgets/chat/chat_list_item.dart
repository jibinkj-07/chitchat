import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/user_profile.dart';
import 'package:chitchat/screens/chat/single_chat_screen.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/general/user_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../logic/database/firebase_operations.dart';

class ChatListItem extends StatelessWidget {
  final String userId;
  final String lstMsg;
  final bool isNew;
  final DateTime time;
  final String currentUserid;
  const ChatListItem({
    super.key,
    required this.userId,
    required this.lstMsg,
    required this.isNew,
    required this.time,
    required this.currentUserid,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          final userDetail = snapshot.data;

          return ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SingleChatScreen(
                    targetUserid: userDetail.id,
                    currentUserid: currentUserid,
                  ),
                ),
              );
            },
            leading: userDetail!.get('imageUrl') == ''
                ? Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (!userDetail
                          .get('status')
                          .toString()
                          .contains('offline'))
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: CircleAvatar(
                              backgroundColor: userDetail
                                      .get('status')
                                      .toString()
                                      .contains('online')
                                  ? appColors.greenColor
                                  : appColors.yellowColor,
                              radius: 8,
                            ),
                          ),
                        )
                    ],
                  )
                : Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            strokeAlign: StrokeAlign.outside,
                            width: .5,
                            color: Colors.grey,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userDetail['imageUrl'],
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
                      if (!userDetail
                          .get('status')
                          .toString()
                          .contains('offline'))
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: CircleAvatar(
                              backgroundColor: userDetail
                                      .get('status')
                                      .toString()
                                      .contains('online')
                                  ? appColors.greenColor
                                  : appColors.yellowColor,
                              radius: 8,
                            ),
                          ),
                        )
                    ],
                  ),
            // title: Text(
            //   userDetail.get('name'),
            //   style: TextStyle(
            //     fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
            //   ),
            // ),
            title: Row(
              children: [
                userDetail.get('name').toString().length > 30
                    ? Text(
                        '${userDetail.get('name').toString().substring(0, 28)}..',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        userDetail.get('name'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                if (userDetail.get('verified'))
                  Icon(
                    Iconsax.verify5,
                    color: AppColors().primaryColor,
                    size: 20,
                  ),
              ],
            ),

            subtitle: lstMsg.length > 30
                ? Text(
                    '${lstMsg.substring(0, 29)}...',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  )
                : Text(
                    lstMsg,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (isNew)
                  Icon(
                    Iconsax.sms_notification5,
                    color: appColors.primaryColor,
                    size: 18,
                  ),
                Text(
                  DateFormat.jm().format(time),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isNew ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          );
        }
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(.2),
            radius: 30,
          ),
          title: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(.2),
            ),
          ),
          subtitle: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(.2),
            ),
          ),
        );
      },
    );
  }
}
