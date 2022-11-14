import 'dart:developer';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: CustomScrollView(
          // A list of sliver widgets.
          slivers: <Widget>[
            BlocBuilder<InternetCubit, InternetState>(
              builder: (context, state) {
                if (state is InternetEnabled) {
                  return CupertinoSliverNavigationBar(
                    backgroundColor: Colors.white,
                    leading: BlocBuilder<InternetCubit, InternetState>(
                      builder: (context, state) {
                        if (state is InternetEnabled &&
                            state.connectionType == ConnectionType.wifi) {
                          return Icon(
                            Iconsax.wifi_square,
                            size: 22,
                            color: appColors.greenColor,
                          );
                        } else if (state is InternetEnabled &&
                            state.connectionType == ConnectionType.mobile) {
                          return Icon(
                            Iconsax.arrange_square_2,
                            size: 22,
                            color: appColors.greenColor,
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    largeTitle: const Text(
                      'All Users',
                      // style: TextStyle(fontSize: 30),
                    ),
                  );
                } else {
                  return CupertinoSliverNavigationBar(
                    backgroundColor: Colors.white,
                    middle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Searching for  network',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                      ],
                    ),
                    largeTitle: const Text(
                      'All Users',
                      // style: TextStyle(fontSize: 30),
                    ),
                  );
                }
              },
            ),
            // This widget fills the remaining space in the viewport.
            // Drag the scrollable area to collapse the CupertinoSliverNavigationBar.
            SliverFillRemaining(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CupertinoSearchTextField(
                      onChanged: (String value) {
                        log('The text has changed to: $value');
                      },
                      onSubmitted: (String value) {
                        log('Submitted text: $value');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
