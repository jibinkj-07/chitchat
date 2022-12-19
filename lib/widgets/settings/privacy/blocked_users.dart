import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/general/image_previewer.dart';
import 'package:chitchat/widgets/settings/privacy/user_detail_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BlockedUsers extends StatelessWidget {
  final String currentUserid;
  const BlockedUsers({
    super.key,
    required this.currentUserid,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          //top section
          topSection(context: context),
          const Divider(height: 0),
          const SizedBox(height: 5),
          infoPart(appColors: appColors),
          Expanded(
            child: listOfUser(currentUserid: currentUserid),
          ),
        ],
      )),
    );
  }

  Widget topSection({required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          splashRadius: 20.0,
          iconSize: 20.0,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Text(
          'Blocked Users',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.transparent,
          ),
          color: Colors.white,
          splashRadius: 20.0,
          iconSize: 20.0,
          onPressed: null,
        ),
      ],
    );
  }

  Widget infoPart({required AppColors appColors}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: appColors.redColor.withOpacity(.2),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: appColors.redColor,
            child: Icon(
              Iconsax.slash,
              size: 40,
              color: appColors.textColorWhite,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(
                Iconsax.information,
                size: 15,
                color: appColors.textColorBlack.withOpacity(.5),
              ),
              const SizedBox(width: 5),
              Text(
                "Find the list of users that you are blocked",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: appColors.textColorBlack.withOpacity(.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget listOfUser({required currentUserid}) {
    AppColors appColors = AppColors();
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserid)
          .collection('blockedUsers')
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: appColors.primaryColor,
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          final length = snapshot.data!.docs.length;
          if (length == 0) {
            return const Center(
              child: Text(
                'No users',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: length,
              itemBuilder: (ctx1, index) {
                return UserDetailList(
                  targetId: snapshot.data!.docs[index].id,
                  time: snapshot.data!.docs[index].get('time').toDate(),
                  currentUserid: currentUserid,
                  isReportedPage: false,
                );
              },
            );
          }
        }
        return const SizedBox();
      },
    );
  }
}
