import 'dart:developer';

import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/cubit/user_detail_cubit.dart';
import 'package:chitchat/screens/auth/authentication_screen.dart';
import 'package:chitchat/screens/auth/login_screen.dart';
import 'package:chitchat/screens/auth/sign_up_screen.dart';
import 'package:chitchat/screens/auth/welcome_screen.dart';
import 'package:chitchat/screens/home_screen.dart';
import 'package:chitchat/utils/custom_route_transition.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  // Step 3
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => HydratedBlocOverrides.runZoned(
      () {
        runApp(MyApp(
          connectivity: Connectivity(),
        ));
        // whenever your initialization is completed, remove the splash screen:
        // FlutterNativeSplash.remove();
      },
      storage: storage,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Connectivity connectivity;
  const MyApp({super.key, required this.connectivity});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //cubit for user details feature
        BlocProvider(
          create: (_) => UserDetailCubit(),
        ), //cubit for Connectivity feature
        BlocProvider(
          create: (_) => InternetCubit(connectivity: connectivity),
        ),
      ],
      child: MaterialApp(
        title: 'Chit Chat',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Poppins',
          //Overall app pagetransition theme
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          }),
        ),
        home: BlocBuilder<UserDetailCubit, UserDetailState>(
          builder: (context, state) {
            if (state.isAuthenticated) {
              return const HomeScreen();
            } else {
              return const WelcomeScreen();
            }
          },
        ),
        routes: {
          '/welcome': (_) => const WelcomeScreen(),
          '/auth': (_) => const AuthenticationScreen(),
          '/login': (_) => const LoginScreen(),
          '/signUp': (_) => const SignUpScreen(),
          '/homeScreen': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
