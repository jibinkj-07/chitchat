import 'package:chitchat/widgets/settings/account/account_deletion.dart';
import 'package:chitchat/widgets/settings/account/change_name.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../utils/app_colors.dart';

class Account extends StatelessWidget {
  final String currentEmail;
  final String id;
  const Account({
    super.key,
    required this.currentEmail,
    required this.id,
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
        elevation: 0,
        title: const Text(
          "Account",
        ),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: appColors.primaryColor,
          splashRadius: 20.0,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: screen.width,
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //user name change button
            Container(
              width: screen.width * .9,
              margin: const EdgeInsets.only(top: 5),
              child: Material(
                color: Colors.grey.withOpacity(.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        reverseDuration: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 300),
                        type: PageTransitionType.rightToLeft,
                        child: ChangeName(id: id),
                      ),
                    );
                  },
                  splashColor: Colors.grey.withOpacity(.5),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: const Text(
                      'Change name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            //account  delete button
            Container(
              width: screen.width * .9,
              margin: const EdgeInsets.only(top: 5),
              child: Material(
                color: Colors.grey.withOpacity(.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   PageTransition(
                    //     reverseDuration: const Duration(milliseconds: 300),
                    //     duration: const Duration(milliseconds: 300),
                    //     type: PageTransitionType.rightToLeft,
                    //     child: const Security(),
                    //   ),
                    // );
                  },
                  splashColor: Colors.grey.withOpacity(.5),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: const Text(
                      'Update profile bio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
            //account  delete button
            Container(
              width: screen.width * .9,
              margin: const EdgeInsets.only(top: 5),
              child: Material(
                color: Colors.grey.withOpacity(.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        reverseDuration: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 300),
                        type: PageTransitionType.rightToLeft,
                        child: AccountDeletion(
                          currentEmail: currentEmail,
                          id: id,
                        ),
                      ),
                    );
                  },
                  splashColor: Colors.grey.withOpacity(.5),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: const Text(
                      'Delete account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
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
