import 'dart:developer';

import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../../utils/login_screen_arguments.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();
    String email = '';

    //submit function
    Future<void> submitEmail(BuildContext ctx) async {
      FocusScope.of(context).unfocus();

      final valid = formKey.currentState!.validate();
      if (valid) {
        setState(() {
          isLoading = true;
        });
        formKey.currentState!.save();
        final result =
            await firebaseOperations.authenticateUser(userEmail: email);
        if (result == 'true') {
          final result =
              await firebaseOperations.getLoginUserDetails(email: email);
          if (!mounted) return;
          Navigator.of(ctx).pushNamedAndRemoveUntil(
            '/login',
            arguments: LoginScreenArguments(
              id: result['id']!,
              username: result['username']!,
              name: result['name']!,
              email: result['email']!,
              imageUrl: result['imageUrl']!,
              verified: result['verified']!,
              bio: result['bio']!,
              joined: result['joined'] as DateTime,
            ),
            (route) => false,
          );
        } else if (result == 'false') {
          if (!mounted) return;
          Navigator.of(ctx).pushNamedAndRemoveUntil(
            '/signUp',
            arguments: email,
            (route) => false,
          );
        } else {
          log('called');
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    //main section
    return Form(
      key: formKey,
      child: Scaffold(
        body: SafeArea(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    //illustration image
                    SvgPicture.asset(
                      'assets/illustrations/auth.svg',
                      height: screen.height * .4,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Continue with your email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    //email textfield
                    SizedBox(
                      width: screen.width * .8,
                      child: TextFormField(
                        cursorColor: appColors.primaryColor,
                        textInputAction: TextInputAction.done,
                        key: const ValueKey('email'),
                        keyboardType: TextInputType.emailAddress,
                        // obscureText: _isObscure,
                        //validation
                        validator: (data) {
                          if (data!.isEmpty) {
                            return 'Email is empty';
                          } else if (!EmailValidator.validate(data)) {
                            return 'Invalid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value.toString().trim();
                        },
                        style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                        //decoration
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          hintText: 'Email address',
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
                            borderSide:
                                BorderSide(width: 1, color: appColors.redColor),
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
                    const SizedBox(height: 10),
                    //next button
                    isLoading
                        ? CircularProgressIndicator(
                            color: appColors.primaryColor,
                            strokeWidth: 1.5,
                          )
                        : SizedBox(
                            width: screen.width * .6,
                            child: BlocBuilder<InternetCubit, InternetState>(
                              builder: (ctx, state) {
                                if (state is InternetEnabled) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: appColors.primaryColor,
                                      foregroundColor: appColors.textColorWhite,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      submitEmail(context);
                                    },
                                    child: const Text(
                                      "Next",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    "Turn on Mobile data or Wifi to continue",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: appColors.redColor),
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
        ),
      ),
    );
  }
}
