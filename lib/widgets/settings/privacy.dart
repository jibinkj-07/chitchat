import 'package:chitchat/logic/cubit/user_detail_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

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
            "Privacy",
          ),
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: appColors.primaryColor,
            splashRadius: 20.0,
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Container(
        width: screen.width,
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //bottom column
            Column(
              children: [
                //password change button
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
                          'Blocked users',
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
          ],
        ),
      ),
    );
  }
}
