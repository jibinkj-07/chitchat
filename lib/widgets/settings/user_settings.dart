import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/hive_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/settings/account.dart';
import 'package:chitchat/widgets/settings/privacy.dart';
import 'package:chitchat/widgets/settings/security.dart';
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
                                  const Duration(milliseconds: 800),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 800),
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
                                  width: 100,
                                  height: 100,
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
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //setting section
                      CupertinoButton(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                              fontSize: 15,
                              color: appColors.primaryColor,
                              fontFamily: 'Poppins'),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  //bio
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "Bio",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Container(
                        width: screen.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          userDetail[0].bio,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 10,
                    thickness: 1,
                  ),
                  const SizedBox(height: 25),
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
                          child: const Privacy(),
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
                          child: const Security(),
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
