import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/widgets/general/user_detail.dart';
import 'package:chitchat/widgets/settings/security/password_reset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../logic/database/hive_operations.dart';
import '../../utils/app_colors.dart';

class Security extends StatelessWidget {
  final String id;
  final String email;
  const Security({
    super.key,
    required this.id,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    final navigator = Navigator.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: screen.width,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //top column
              Column(
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
                        'Security',
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
                  const SizedBox(height: 5),
                  //account page buttons],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Iconsax.information,
                        size: 15,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Manage and review your security related settings",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PasswordReset(email: email),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          //arrow icon
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //bottom column

              InkWell(
                onTap: () async {
                  FirebaseOperations()
                      .changeStatus(userId: id, status: 'offline');
                  await deleteAccountHive();
                  await FirebaseAuth.instance.signOut();
                  navigator.pushNamedAndRemoveUntil('/auth', (route) => false);
                },
                splashColor: appColors.redColor.withOpacity(.2),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.redColor,
                        ),
                      ),
                      //arrow icon
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: appColors.redColor,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
