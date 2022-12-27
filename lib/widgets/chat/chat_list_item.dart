import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/single_chat_screen.dart';
import 'package:chitchat/widgets/general/image_previewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    AppColors appColors = AppColors();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(targetUserid)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          final userDetail = snapshot.data;
          final name = userDetail!.get('name').toString().length > 30
              ? '${userDetail.get('name').toString().substring(0, 28)}..'
              : userDetail.get('name');

          return ListTile(
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => SingleChatScreen(
                  targetUserid: targetUserid,
                  currentUserid: currentUserid,
                ),
              ),
              (route) => false,
            ),
            leading: Stack(
              children: [
                ImagePreviewer(
                  targetUserid: userDetail.id,
                  height: 50,
                  width: 50,
                  url: userDetail.get('imageUrl'),
                ),
                if (!userDetail.get('status').toString().contains('offline'))
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: appColors.textColorWhite,
                      radius: 8,
                      child: CircleAvatar(
                        backgroundColor: userDetail
                                .get('status')
                                .toString()
                                .contains('online')
                            ? appColors.greenColor
                            : appColors.yellowColor,
                        radius: 6,
                      ),
                    ),
                  )
              ],
            ),
            horizontalTitleGap: 8.0,
            title: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isNew ? FontWeight.bold : FontWeight.w500,
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
            subtitle: Text(
              lastMessage,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (isNew)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: appColors.primaryColor,
                    child: Text(
                      unreadCount.toString(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: appColors.textColorWhite),
                    ),
                  ),
                Text(
                  time,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isNew ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
