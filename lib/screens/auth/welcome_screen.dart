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
          child: WelcomeBody(screen: screen, appColors: appColors),
        ),
      ),
    );
  }
}

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({
    Key? key,
    required this.screen,
    required this.appColors,
  }) : super(key: key);

  final Size screen;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Illustration image part
        SvgPicture.asset(
          'assets/illustrations/welcome.svg',
          height: screen.height * .4,
        ),
        SizedBox(
          width: screen.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //onboard text
              Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: appColors.textDarkColor,
                ),
              ),
              Text(
                "ChitChat",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryColor,
                ),
              ),
              const Text(
                "Connect with your favourites",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ],
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
    );
  }
}
