import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/user_profile.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/message_body.dart';
import 'package:chitchat/widgets/chat/message_controls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
    final screen = MediaQuery.of(context).size;
    AppColors appColors = AppColors();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //chat screen top bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(targetUserid)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Center(
                  //     child: CupertinoActivityIndicator(
                  //       radius: 30,
                  //       color: appColors.primaryColor,
                  //     ),
                  //   );
                  // }
                  if (snapshot.hasData) {
                    return Row(
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
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
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
                                    : Colors.grey,
                              ),
                            )
                          ],
                        )
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            const Divider(height: 0),
            //chat screen message body
            Expanded(
              child: MessageBody(
                currentUserid: currentUserid,
                targetUserid: targetUserid,
              ),
            ),
            const Divider(height: 0),
            //chat screen message controller
            MessageControls(
              senderId: currentUserid,
              targetId: targetUserid,
            ),
          ],
        ),
      ),
    );
  }
}
