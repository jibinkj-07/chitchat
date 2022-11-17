import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/login_screen_arguments.dart';
import 'package:flutter/material.dart';

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
    FirebaseOperations firebaseOperations = FirebaseOperations();
    final args =
        ModalRoute.of(context)!.settings.arguments as LoginScreenArguments;
    String password = '';

    //submitting password
    void submitPassword() {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        setState(() {
          isLoading = true;
        });
        formKey.currentState!.save();
        firebaseOperations.loginUser(
          email: args.email,
          password: password,
          name: args.name,
          id: args.id,
          bio: args.bio,
          imageUrl: args.imageUrl,
          context: context,
        );
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
          child: SingleChildScrollView(
            child: Container(
              width: screen.width,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Profile picture
                  CircleAvatar(
                    radius: 90,
                    backgroundColor: appColors.primaryColor.withOpacity(.3),
                    child: CircleAvatar(
                        radius: 85,
                        backgroundColor: appColors.primaryColor.withOpacity(.8),
                        child: args.imageUrl == ''
                            ? const CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    AssetImage('assets/images/profile.png'),
                              )
                            : CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(args.imageUrl),
                              )),
                  ),
                  const SizedBox(height: 10),
                  //login text
                  Text(
                    'Hi ${args.name}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appColors.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  //email text
                  Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: appColors.textDarkColor,
                    ),
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
                          if (data!.isEmpty) {
                            return 'Enter a password';
                          } else if (data.length < 6) {
                            return 'Minimum 6 characters required';
                          }
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
                              isVisible ? Icons.lock_outline : Icons.lock_open,
                              // size: 20,
                              // color: appColors.primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                              });
                            },
                            splashColor: appColors.primaryColor.withOpacity(.7),
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
                  ),

                  //forget password button
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.of(context).pushNamed('/pwReset');
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
                          width: screen.width * .8,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.primaryColor,
                              foregroundColor: appColors.textLightColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: submitPassword,
                            child: const Text(
                              "Login",
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
    );
  }
}
