import 'dart:developer';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/cubit/replying_message_cubit.dart';
import 'package:chitchat/logic/database/user_model.dart';
import 'package:chitchat/recorder.dart';
import 'package:chitchat/voice_message.dart';
import 'package:chitchat/widgets/chat/gallery_preview_picker.dart';
import 'package:chitchat/screens/auth/authentication_screen.dart';
import 'package:chitchat/screens/auth/login_screen.dart';
import 'package:chitchat/screens/auth/sign_up_screen.dart';
import 'package:chitchat/screens/auth/welcome_screen.dart';
import 'package:chitchat/screens/home_screen.dart';
import 'package:chitchat/utils/chitchat_themes.dart';
import 'package:chitchat/utils/custom_route_transition.dart';
import 'package:chitchat/widgets/general/image_updating.dart';
import 'package:chitchat/widgets/settings/security/password_reset.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
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
        FlutterNativeSplash.remove();
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
        //cubit for Connectivity feature
        BlocProvider(
          create: (_) => InternetCubit(connectivity: connectivity),
        ),
        BlocProvider(
          create: (_) => ReplyingMessageCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Chit Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            },
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return HomeScreen(index: 0);
            }
            return const WelcomeScreen();
          },
        ),
        // home: VoiceMessage(),
        routes: {
          '/welcome': (_) => const WelcomeScreen(),
          '/auth': (_) => const AuthenticationScreen(),
          '/login': (_) => const LoginScreen(),
          '/signUp': (_) => const SignUpScreen(),
          '/homeScreen': (_) => HomeScreen(index: 0),
        },
      ),
    );
  }
}
