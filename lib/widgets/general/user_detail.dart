import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/widgets/general/image_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../logic/database/user_profile.dart';
import '../../utils/app_colors.dart';
import '../chat/single_chat_screen.dart';

class UserDetail extends StatelessWidget {
  final UserProfile targetUser;
  final String currentUserid;
  const UserDetail({
    super.key,
    required this.targetUser,
    required this.currentUserid,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.black,
                  splashRadius: 20.0,
                  iconSize: 20.0,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  'Find Friends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    disabledForegroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Edit',
                  ),
                )
              ],
            ),
            const Divider(height: 0),

            //User info detail section

            Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: screen.width,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        //user image section
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ImagePreview(
                                  id: targetUser.id,
                                  url: targetUser.imageUrl,
                                  title: 'Find Friends',
                                  isEditable: false,
                                ),
                              ),
                            );
                          },
                          child: targetUser.imageUrl == ''
                              ? Hero(
                                  tag: targetUser.id,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: .5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/profile.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                )
                              : Hero(
                                  tag: targetUser.id,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: .5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: targetUser.imageUrl,
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                color: appColors.primaryColor,
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error,
                                          color: appColors.redColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 5),
                        //Name
                        Text(
                          targetUser.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        //email

                        Text(
                          targetUser.username,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        //verfication mark
                        if (targetUser.isVerified)
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

                        const SizedBox(height: 20),
                        //bio
                        Container(
                          width: screen.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            targetUser.bio,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!targetUser.isVerified)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.information,
                                size: 15,
                                color: appColors.redColor.withOpacity(.8),
                              ),
                              const SizedBox(width: 5),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(targetUser.id)
                                    .collection('usersReported')
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    final count = snapshot.data!.docs.length;

                                    final text = count > 1
                                        ? '$count Users reported this account'
                                        : count == 1
                                            ? '1 User reported this account'
                                            : '0 User reported this account';
                                    return Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            appColors.redColor.withOpacity(.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ],
                          ),
                        const SizedBox(height: 30), //message button
                        if (currentUserid != targetUser.id)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.primaryColor,
                              foregroundColor: appColors.textColorWhite,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SingleChatScreen(
                                    targetUserid: targetUser.id,
                                    currentUserid: currentUserid,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Message",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
