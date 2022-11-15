import 'package:chitchat/logic/cubit/user_detail_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/settings/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    return BlocBuilder<UserDetailCubit, UserDetailState>(builder: (ctx, state) {
      return Column(
        children: [
          //profile image
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 3,
                color: appColors.primaryColor,
              ),
            ),
            child: state.profilePicUrl == ''
                ? CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.black.withOpacity(.1),
                    backgroundImage:
                        const AssetImage('assets/images/profile_light.png'),
                  )
                : CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.black.withOpacity(.1),
                    backgroundImage: NetworkImage(state.profilePicUrl),
                  ),
          ),

          //name
          Text(
            state.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          //email
          Text(
            state.email,
            style: const TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          //bio section

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Bio",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              Container(
                width: screen.width * .9,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  state.bio,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          //account bar
          Container(
            width: screen.width * .9,
            margin: const EdgeInsets.only(top: 5),
            child: Material(
              color: Colors.blue.withOpacity(.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: InkWell(
                splashColor: Colors.blue.withOpacity(.5),
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            CupertinoIcons.person_alt,
                            size: 28,
                            color: Colors.blue,
                          ),
                          Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //privacy bar
          Container(
            width: screen.width * .9,
            margin: const EdgeInsets.only(top: 5),
            child: Material(
              color: Colors.blue.withOpacity(.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: InkWell(
                splashColor: Colors.blue.withOpacity(.5),
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            CupertinoIcons.lock,
                            size: 28,
                            color: Colors.blue,
                          ),
                          Text(
                            'Privacy',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //account bar
          Container(
            width: screen.width * .9,
            margin: const EdgeInsets.only(top: 5),
            child: Material(
              color: Colors.blue.withOpacity(.2),
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
                      child: const Security(),
                    ),
                  );
                },
                splashColor: Colors.blue.withOpacity(.5),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            CupertinoIcons.shield,
                            size: 28,
                            color: Colors.blue,
                          ),
                          Text(
                            'Security',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
