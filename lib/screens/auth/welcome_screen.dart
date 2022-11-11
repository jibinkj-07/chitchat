import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final AppColors appColors = AppColors();
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //Illustration image part
            SvgPicture.asset(
              'assets/illustrations/welcome.svg',
              height: screen.height * .7,
            ),
            //onboard text
            Text(
              "Chitchat",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: appColors.textDarkColor,
              ),
            ),
            //lets start button
            SizedBox(
              width: screen.width * .8,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.primaryColor,
                  foregroundColor: appColors.textLightColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/auth', (route) => false);
                },
                child: const Text(
                  "Lets Start",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
