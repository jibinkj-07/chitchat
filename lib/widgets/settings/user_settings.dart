import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/hive_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/settings/account.dart';
import 'package:chitchat/widgets/settings/edit_profile.dart';
import 'package:chitchat/widgets/settings/privacy.dart';
import 'package:chitchat/widgets/settings/security.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';
import '../../logic/database/user_model.dart';
import '../general/image_preview.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    AppColors appColors = AppColors();
    return ValueListenableBuilder(
        valueListenable: userDetailNotifier,
        builder: (BuildContext ctx, List<UserModel> userDetail, Widget? child) {
          try {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //profile section
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //user image
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 500),
                              pageBuilder: (_, __, ___) => ImagePreview(
                                id: userDetail[0].id,
                                url: userDetail[0].imageUrl,
                                title: 'Settings',
                                isEditable: true,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: userDetail[0].id,
                          child: userDetail[0].imageUrl == ''
                              ? Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: .5,
                                      color: Colors.grey.withOpacity(.5),
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/profile.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: .5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: userDetail[0].imageUrl,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              color: appColors.primaryColor,
                                              value: downloadProgress.progress),
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
                      const SizedBox(height: 10),
                      //name and email

                      Text(
                        userDetail[0].name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userDetail[0].id)
                              .snapshots(),
                          builder:
                              (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.get('verified')) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.verify5,
                                      size: 20,
                                      color: appColors.primaryColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Verified Account',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: appColors.primaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              } else {}
                              return const SizedBox();
                            }
                            return const SizedBox();
                          }),
                      //setting section
                      CupertinoButton(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                              fontSize: 15,
                              color: appColors.primaryColor,
                              fontFamily: 'Poppins'),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              reverseDuration:
                                  const Duration(milliseconds: 300),
                              duration: const Duration(milliseconds: 300),
                              type: PageTransitionType.bottomToTop,
                              child: EditProfile(
                                id: userDetail[0].id,
                                name: userDetail[0].name,
                                url: userDetail[0].imageUrl,
                                bio: userDetail[0].bio,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  //bio
                  SizedBox(
                    width: screen.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Profile Bio",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          userDetail[0].bio,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  SizedBox(
                    width: screen.width,
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const Divider(),
                  //account
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          reverseDuration: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 300),
                          type: PageTransitionType.rightToLeft,
                          child: Account(
                            currentEmail: userDetail[0].email,
                            id: userDetail[0].id,
                            name: userDetail[0].name,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Iconsax.user,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          //arrow icon
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
//privacy
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          reverseDuration: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 300),
                          type: PageTransitionType.rightToLeft,
                          child: Privacy(
                            id: userDetail[0].id,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Iconsax.key,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Privacy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          //arrow icon
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                  //security
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          reverseDuration: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 300),
                          type: PageTransitionType.rightToLeft,
                          child: Security(
                            id: userDetail[0].id,
                            email: userDetail[0].email,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Iconsax.shield_tick,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Security',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          //arrow icon
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } catch (e) {
            log("error at user setting ${e.toString()}");
            return Center(
              child: CircularProgressIndicator(
                color: AppColors().primaryColor,
                strokeWidth: 1.5,
              ),
            );
          }
        });
  }
}
