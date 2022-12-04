import 'dart:developer';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../widgets/settings/user_settings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SettingScreenBody(screen: screen, appColors: appColors),
        ),
      ),
    );
  }
}

class SettingScreenBody extends StatelessWidget {
  const SettingScreenBody({
    Key? key,
    required this.screen,
    required this.appColors,
  }) : super(key: key);

  final Size screen;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: screen.width,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          color: appColors.textColorWhite,
          // height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BlocBuilder<InternetCubit, InternetState>(
                builder: (ctx, state) {
                  if (state is InternetEnabled) {
                    return CircleAvatar(
                      radius: 8.0,
                      backgroundColor: appColors.greenColor.withOpacity(.5),
                      child: CircleAvatar(
                        radius: 6.0,
                        backgroundColor: appColors.greenColor,
                      ),
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Searching for network",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: appColors.textColorBlack.withOpacity(.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: appColors.textColorBlack.withOpacity(.7),
                            strokeWidth: 1.5,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: appColors.textColorBlack,
                    ),
                  ),
                  IconButton(
                    onPressed: null,
                    color: appColors.textColorWhite,
                    disabledColor: appColors.textColorWhite,
                    icon: const Icon(
                      Iconsax.search_normal_1,
                    ),
                    splashRadius: 20.0,
                  ),
                ],
              ),
              //implement search bar here
            ],
          ),
        ),
        Divider(
          height: 0,
          color: appColors.textColorBlack.withOpacity(.3),
        ),
        const Expanded(
          child: SingleChildScrollView(
            child: UserSettings(),
          ),
        ),
      ],
    );
  }
}
