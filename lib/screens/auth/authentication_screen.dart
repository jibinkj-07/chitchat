import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_colors.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final AppColors appColors = AppColors();
    String email = '';

    //submit function
    void submitEmail() {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        formKey.currentState!.save();
        Navigator.of(context).pushNamed('/signUp');
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
                      'assets/illustrations/login.svg',
                      height: screen.height * .4,
                    ),
                    const SizedBox(height: 30),
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
                    SizedBox(
                      width: screen.width * .8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.primaryColor,
                          foregroundColor: appColors.textLightColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: submitEmail,
                        child: const Text(
                          "Next",
                          style: TextStyle(fontSize: 16),
                        ),
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
