import 'dart:developer';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              BlocBuilder<InternetCubit, InternetState>(
                builder: (context, state) {
                  if (state is InternetEnabled) {
                    return CupertinoSliverNavigationBar(
                      backgroundColor: Colors.white,
                      leading: BlocBuilder<InternetCubit, InternetState>(
                        builder: (context, state) {
                          if (state is InternetEnabled &&
                              state.connectionType == ConnectionType.wifi) {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor:
                                      appColors.greenColor.withOpacity(.5),
                                  child: CircleAvatar(
                                    radius: 6,
                                    backgroundColor: appColors.greenColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.network_wifi_rounded,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ],
                            );
                          } else if (state is InternetEnabled &&
                              state.connectionType == ConnectionType.mobile) {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor:
                                      appColors.greenColor.withOpacity(.5),
                                  child: CircleAvatar(
                                    radius: 6,
                                    backgroundColor: appColors.greenColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.network_cell_rounded,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ],
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
                            'Searching for network',
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
            ];
          },
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children: [
                  // const SizedBox(height: 30),
                  CupertinoSearchTextField(
                    onChanged: (String value) {
                      log('The text has changed to: $value');
                    },
                    onSubmitted: (String value) {
                      log('Submitted text: $value');
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 50,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 50,
                          child: Center(
                              child: Material(child: Text('Entry $index'))),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
