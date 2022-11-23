import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PasswordReset extends StatelessWidget {
  final String email;
  const PasswordReset({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;

    //dialog box for no internet warning
    void showAlertBox(BuildContext context, String title) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext ctx) => CupertinoAlertDialog(
          title: Text(title),
          // content: const Text(
          //     'Make sure you have turned on Mobile data or Wifi to continue.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    void resetPassword() async {
      final result = await FirebaseOperations().resetPassword(email: email);
      if (result.trim().contains('success')) {
        showAlertBox(context, 'Password reset mail sent');
      } else {
        showAlertBox(context, 'Something went wrong. Try again later');
      }
    }

    //main
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
                  'Password',
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
            ),
            const Divider(
              height: 0,
            ),
            Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Iconsax.information,
                              size: 15,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "You can reset your password if you really forgot. Keep your password strong and secure to avoid account security breaches.",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      //body
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: appColors.primaryColor.withOpacity(.2),
                        child: Icon(
                          CupertinoIcons.lock_circle_fill,
                          size: 60,
                          color: appColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Follow below instructions to reset your password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '1. ',
                          ),
                          SizedBox(
                            width: screen.width * .9,
                            child: const Text(
                              "Click on the 'Send Mail' button below to send password reset mail",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '2. ',
                          ),
                          SizedBox(
                            width: screen.width * .9,
                            child: const Text(
                              "Go to your mailbox and check for Password Reset mail",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.information,
                            size: 15,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            width: screen.width * .8,
                            child: const Text(
                              "Check in Spam/Junk folder if mail not found in Inbox folder",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '3. ',
                          ),
                          SizedBox(
                            width: screen.width * .9,
                            child: const Text(
                              "Click on the link provided in mail and reset your password",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //button
                      ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: const Text("Send Mail"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
