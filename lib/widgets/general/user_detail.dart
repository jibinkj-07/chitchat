import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/user_profile.dart';
import 'package:chitchat/widgets/general/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: appColors.primaryColor,
        title: const Text(
          'Profile Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: appColors.primaryColor,
          iconSize: 20,
          splashRadius: 20.0,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            width: screen.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ImagePreview(
                          id: user.id,
                          url: user.url,
                          title: 'Profile Info',
                          isEditable: false,
                        ),
                      ),
                    );
                  },
                  child: user.url == ''
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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.url,
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
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
                        ),
                ),

                //name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                //email
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                //message button
                if (currentId != user.id)
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      width: 80,
                      height: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: appColors.primaryColor.withOpacity(.15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.sms5,
                            size: 30,
                            color: appColors.primaryColor,
                          ),
                          Text(
                            "Connect",
                            style: TextStyle(
                              fontSize: 13,
                              color: appColors.primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                //bio section

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        "Bio",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      width: screen.width * .9,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: appColors.primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        user.bio,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
