import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                      const SizedBox(height: 5),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: appColors.primaryColor.withOpacity(.2),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: appColors.primaryColor,
                          child: const Icon(
                            Iconsax.lock_15,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                              "If you really forgot your password you can reset it. Keep your password strong and secure to avoid account security breaches.",
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

                      const SizedBox(height: 30),
                      const Text(
                        "Follow below instructions to reset your password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '1. ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: screen.width * .9,
                            child: const Text(
                              "Click on the 'Send Mail' button below to send password reset mail",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: screen.width * .9,
                            child: const Text(
                              "Go to your mailbox and check for Password Reset mail",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
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
                                fontWeight: FontWeight.w500,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: screen.width * .9,
                            child: const Text(
                              "Click on the link provided in mail and reset your password",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //button
                      BlocBuilder<InternetCubit, InternetState>(
                        builder: (context, state) {
                          if (state is InternetEnabled) {
                            return ElevatedButton(
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
                            );
                          } else {
                            return const Text(
                              "Turn on Mobile data or Wifi to continue",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                        },
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
