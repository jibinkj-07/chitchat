import 'dart:developer';

import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/login_screen_arguments.dart';
import 'package:chitchat/widgets/settings/security/password_reset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  FirebaseOperations firebaseOperations = FirebaseOperations();
  bool isVisible = false;
  bool isLoading = false;
  //main section
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final AppColors appColors = AppColors();
    final args =
        ModalRoute.of(context)!.settings.arguments as LoginScreenArguments;
    String password = '';

    //submitting password
    void submitPassword() async {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        setState(() {
          isLoading = true;
        });
        formKey.currentState!.save();
        bool result = await firebaseOperations.loginUser(
          email: args.email,
          password: password,
          name: args.name,
          username: args.username,
          id: args.id,
          bio: args.bio,
          imageUrl: args.imageUrl,
          joined: args.joined,
          context: context,
        );
        log('result is $result');
        if (!result) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    //main section
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                child: Text(
                  "Login to Your Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: screen.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //Profile picture
                        args.imageUrl == ''
                            ? Container(
                                width: 180,
                                height: 180,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/profile.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : Container(
                                width: 180,
                                height: 180,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: args.imageUrl,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            color: appColors.primaryColor,
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: appColors.redColor,
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 40),
                        //login text
                        Text(
                          'Hi ${args.name}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.normal,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),
                        //password textfield
                        Form(
                          key: formKey,
                          child: SizedBox(
                            width: screen.width * .8,
                            child: TextFormField(
                              cursorColor: appColors.primaryColor,
                              key: const ValueKey('password'),
                              textInputAction: TextInputAction.done,
                              obscureText: !isVisible,
                              //validator
                              validator: (data) {
                                if (data!.trim().isEmpty) {
                                  return 'Enter a password';
                                } else if (data.trim().length < 6) {
                                  return 'Minimum 6 characters required';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                password = value.toString().trim();
                              },
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),

                              //decoration
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  color: appColors.primaryColor,
                                  icon: Icon(
                                    isVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    // size: 20,
                                    // color: appColors.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isVisible = !isVisible;
                                    });
                                  },
                                  splashColor:
                                      appColors.primaryColor.withOpacity(.7),
                                  splashRadius: 20,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.grey.withOpacity(.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: appColors.primaryColor,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      width: 1, color: appColors.redColor),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    width: 1.5,
                                    color: appColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        //forget password button
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PasswordReset(email: args.email),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: appColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Reset Password",
                          ),
                        ),
                        //Login button
                        isLoading
                            ? CircularProgressIndicator(
                                color: appColors.primaryColor,
                                strokeWidth: 1.5,
                              )
                            : SizedBox(
                                width: screen.width * .6,
                                child:
                                    BlocBuilder<InternetCubit, InternetState>(
                                  builder: (ctx, state) {
                                    if (state is InternetEnabled) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              appColors.primaryColor,
                                          foregroundColor:
                                              appColors.textLightColor,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: submitPassword,
                                        child: const Text(
                                          "Login",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        "Turn on Mobile data or Wifi to continue",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: appColors.redColor),
                                      );
                                    }
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
