import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_colors.dart';
import '../../general/image_previewer.dart';

class UserDetailList extends StatelessWidget {
  final String targetId;
  final String currentUserid;
  final bool isReportedPage;
  final DateTime time;

  const UserDetailList({
    super.key,
    required this.targetId,
    required this.currentUserid,
    required this.isReportedPage,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(targetId)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          final name = snapshot.data!.get('name');
          final url = snapshot.data!.get('imageUrl');
          final isVerified = snapshot.data!.get('verified');
          final subtitle = isReportedPage
              ? 'Reported on ${DateFormat.yMMMEd().add_jm().format(time)}'
              : 'Blocked on ${DateFormat.yMMMEd().add_jm().format(time)}';
          return ListTile(
            horizontalTitleGap: 8.0,
            leading: ImagePreviewer(
              targetUserid: targetId,
              width: 45,
              height: 45,
              url: url,
            ),
            title: Row(
              children: [
                name.length > 30
                    ? Text(
                        '${name.substring(0, 28)}..',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                if (isVerified)
                  Icon(
                    Iconsax.verify5,
                    color: AppColors().primaryColor,
                    size: 20,
                  ),
              ],
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
            trailing: isReportedPage
                ? const SizedBox()
                : TextButton(
                    onPressed: () {
                      FirebaseOperations().unBlockAccount(
                        targetUserid: targetId,
                        currentUserid: currentUserid,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors().textColorBlack,
                    ),
                    child: const Text('Unblock'),
                  ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
