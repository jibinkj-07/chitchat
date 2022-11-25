import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/user_profile.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/message_body.dart';
import 'package:chitchat/widgets/chat/message_controls.dart';
import 'package:flutter/material.dart';

class SingleChatScreen extends StatelessWidget {
  const SingleChatScreen({
    super.key,
    required this.currentUser,
    required this.targetUser,
  });
  final UserProfile currentUser;
  final UserProfile targetUser;

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.black,
                    splashRadius: 20.0,
                    iconSize: 20.0,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                  ),
                  targetUser.imageUrl == ''
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
                              imageUrl: targetUser.imageUrl,
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
                      Text(
                        targetUser.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'typing...',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: appColors.greenColor,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const Divider(height: 0),
            //chat screen message body
            Expanded(
              child: MessageBody(),
            ),
            const Divider(),
            //chat screen message controller
            MessageControls(
              senderId: currentUser.id,
              targetId: targetUser.id,
            ),
          ],
        ),
      ),
    );
  }
}
