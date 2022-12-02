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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0.0,
        backgroundColor: appColors.primaryColor,
        elevation: 0,
      ),
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
                return Column(
                  children: [
                    Material(
                      color: appColors.primaryColor,
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
                        ),
                      ),
                    ),
                    const Divider(height: 0),

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
        required AppColors appColors}) =>
    Row(
      //back arrow
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          iconSize: 20.0,
          splashRadius: 20.0,
          splashColor: Colors.white60,
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
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                status,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
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
          color: Colors.white,
          splashColor: Colors.white60,
        ),
      ],
    );
