import 'dart:developer';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

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
          child: ChatScreenBody(screen: screen, appColors: appColors),
        ),
      ),
    );
  }
}

class ChatScreenBody extends StatelessWidget {
  const ChatScreenBody({
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          width: screen.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BlocBuilder<InternetCubit, InternetState>(
                builder: (ctx, state) {
                  if (state is InternetEnabled) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 8.0,
                          backgroundColor: appColors.greenColor.withOpacity(.5),
                          child: CircleAvatar(
                            radius: 5.0,
                            backgroundColor: appColors.greenColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Active",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Searching for network",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
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
              const Text(
                "Chats",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoSearchTextField(),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (ctx, i) {
              return ListTile(
                leading: CircleAvatar(),
                title: Text('User ${i + 1}'),
                subtitle: Text("New message"),
              );
            },
          ),
        )
      ],
    );
  }
}
