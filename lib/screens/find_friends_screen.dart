import 'dart:developer';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/allUsers/allFriends_search.dart';
import 'package:chitchat/widgets/allUsers/find_friends.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/database/hive_operations.dart';
import '../logic/database/user_model.dart';
import '../logic/database/user_profile.dart';

class FindFriendsScreen extends StatelessWidget {
  const FindFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: FindFriendsScreenBody(screen: screen, appColors: appColors),
        ),
      ),
    );
  }
}

class FindFriendsScreenBody extends StatelessWidget {
  const FindFriendsScreenBody({
    Key? key,
    required this.screen,
    required this.appColors,
  }) : super(key: key);

  final Size screen;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: userDetailNotifier,
        builder: (BuildContext ctx, List<UserModel> userDetail, Widget? child) {
          try {
            UserProfile currentUser = UserProfile(
              id: userDetail[0].id,
              name: userDetail[0].name,
              username: userDetail[0].username,
              imageUrl: userDetail[0].imageUrl,
              isVerified: false,
              bio: userDetail[0].bio,
            );

            //main
            return Column(
              children: [
                Container(
                  width: screen.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
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
                              backgroundColor:
                                  appColors.greenColor.withOpacity(.5),
                              child: CircleAvatar(
                                radius: 5.0,
                                backgroundColor: appColors.greenColor,
                              ),
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Searching for network",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 5),
                                CupertinoActivityIndicator(
                                  color: Colors.black,
                                  radius: 8.0,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Find Friends",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AllFriendsSearch(
                                    currentUser: currentUser,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              CupertinoIcons.search,
                            ),
                            splashRadius: 20.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FindFriends(
                    currentUser: currentUser,
                  ),
                )
              ],
            );
          } catch (e) {
            log("error at find friends ${e.toString()}");
            return Center(
              child: CircularProgressIndicator(
                color: AppColors().primaryColor,
                strokeWidth: 1.5,
              ),
            );
          }
        });
  }
}
