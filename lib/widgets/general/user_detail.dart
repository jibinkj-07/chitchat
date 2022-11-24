import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/widgets/general/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../logic/database/user_profile.dart';
import '../../utils/app_colors.dart';

class UserDetail extends StatelessWidget {
  final UserProfile user;
  final String currentId;
  const UserDetail({
    super.key,
    required this.user,
    required this.currentId,
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
                        const SizedBox(height: 40),
                        //user image section
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ImagePreview(
                                  id: user.id,
                                  url: user.imageUrl,
                                  title: 'Find Friends',
                                  isEditable: false,
                                ),
                              ),
                            );
                          },
                          child: user.imageUrl == ''
                              ? Hero(
                                  tag: user.id,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
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
                                  tag: user.id,
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
                                        imageUrl: user.imageUrl,
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
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        //email
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        //message button
                        if (currentId != user.id)
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Iconsax.message_circle5,
                            ),
                            color: appColors.primaryColor,
                            iconSize: 50,
                            splashColor: appColors.primaryColor.withOpacity(.5),
                            splashRadius: 30,
                          ),
                        const SizedBox(height: 20),
                        //bio
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Profile Bio",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                user.bio,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: appColors.primaryColor,
                                ),
                              ),
                            ],
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
