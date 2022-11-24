import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/app_colors.dart';

class Privacy extends StatelessWidget {
  final String id;
  const Privacy({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: screen.width,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    'Privacy',
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
              //account page buttons
              Column(
                children: [
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
                        "Manage and review your privacy related settings",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  //buttons
                  InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   PageTransition(
                      //     reverseDuration: const Duration(milliseconds: 300),
                      //     duration: const Duration(milliseconds: 300),
                      //     type: PageTransitionType.rightToLeft,
                      //     child: Account(
                      //       currentEmail: userDetail[0].email,
                      //       id: userDetail[0].id,
                      //     ),
                      //   ),
                      // );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Blocked Users',
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

                  InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   PageTransition(
                      //     reverseDuration: const Duration(milliseconds: 300),
                      //     duration: const Duration(milliseconds: 300),
                      //     type: PageTransitionType.rightToLeft,
                      //     child: Account(
                      //       currentEmail: userDetail[0].email,
                      //       id: userDetail[0].id,
                      //     ),
                      //   ),
                      // );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Users Reported',
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
            ],
          ),
        ),
      ),
    );
  }
}
