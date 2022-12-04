import 'package:chitchat/widgets/chat/chat_body.dart';
import 'package:chitchat/widgets/general/image_previewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/app_colors.dart';

class SingleChatScreen extends StatelessWidget {
  final String targetUserid;
  final String currentUserid;
  const SingleChatScreen({
    super.key,
    required this.targetUserid,
    required this.currentUserid,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
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
                          targetUserid: targetUserid,
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
                          currentUserid: currentUserid,
                          targetUserid: targetUserid,
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
}

Widget chatTopBar(
        {required BuildContext context,
        required String targetUserid,
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
            Navigator.of(context).pop();
          },
          color: appColors.textColorBlack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          iconSize: 20.0,
          splashRadius: 20.0,
        ),
        //image
        ImagePreviewer(
            targetUserid: targetUserid, width: 40, height: 40, url: url),
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

        //clear chat button
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.broom),
          splashRadius: 20.0,
          color: appColors.textColorBlack,
        ),
      ],
    );
