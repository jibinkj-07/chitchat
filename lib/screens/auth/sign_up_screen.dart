import 'dart:developer';
import 'dart:io';

import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/image_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  bool isLoading = false;
  File? imageFile;

  //main section
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();
    final userEmail =
        ModalRoute.of(context)!.settings.arguments.toString().trim();
    String password = '';
    String name = '';

    //submitting password
    void createAccount() async {
      final navigator = Navigator.of(context);
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        setState(() {
          isLoading = true;
        });
        formKey.currentState!.save();
        final result = await firebaseOperations.createNewUser(
          email: userEmail,
          password: password,
          name: name,
          context: context,
          userImage: imageFile,
        );
        if (result == 'success') {
          // //ROUTING USER TO HOMEPAGE
          navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    //main section
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: screen.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                //Profile picture
                                imageFile == null
                                    ? GestureDetector(
                                        onTap: () {
                                          changeProfilePicture();
                                        },
                                        child: Container(
                                          width: 180,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appColors.primaryColor,
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/profile.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          changeProfilePicture();
                                        },
                                        child: Container(
                                          width: 180,
                                          height: 180,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: Image.file(
                                              imageFile!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),

                                CupertinoButton(
                                  onPressed: () {
                                    changeProfilePicture();
                                  },
                                  child: Text(
                                    'Edit Photo',
                                    style: TextStyle(
                                      color: appColors.primaryColor,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                            //password textfield
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  //user name field
                                  SizedBox(
                                    width: screen.width * .8,
                                    child: TextFormField(
                                      cursorColor: appColors.primaryColor,
                                      key: const ValueKey('username'),
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      //validator
                                      validator: (data) {
                                        if (data!.isEmpty) {
                                          return 'Name is empty';
                                        }
                                      },
                                      onSaved: (value) {
                                        name = value.toString().trim();
                                      },
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),

                                      //decoration
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 15),
                                        hintText: 'Name',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey.withOpacity(.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 1.5,
                                            color: appColors.primaryColor,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: appColors.redColor),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 1.5,
                                            color: appColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  //password field
                                  SizedBox(
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
                                            isVisible
                                                ? Icons.lock_outline
                                                : Icons.lock_open,
                                            // size: 20,
                                            // color: appColors.primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isVisible = !isVisible;
                                            });
                                          },
                                          splashColor: appColors.primaryColor
                                              .withOpacity(.7),
                                          splashRadius: 20,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 15),
                                        hintText: 'Password',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey.withOpacity(.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 1.5,
                                            color: appColors.primaryColor,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: appColors.redColor),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            width: 1.5,
                                            color: appColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            //Login button
                            isLoading
                                ? CircularProgressIndicator(
                                    color: appColors.primaryColor,
                                    strokeWidth: 1.5,
                                  )
                                : SizedBox(
                                    width: screen.width * .5,
                                    child: BlocBuilder<InternetCubit,
                                        InternetState>(
                                      builder: (ctx, state) {
                                        if (state is InternetEnabled) {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  appColors.primaryColor,
                                              foregroundColor:
                                                  appColors.textLightColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            onPressed: createAccount,
                                            child: const Text(
                                              "Create",
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This shows a CupertinoModalPopup which hosts a CupertinoActionSheet.
  void changeProfilePicture() {
    ImageChooser imageChooser = ImageChooser();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final image = await imageChooser.getFromGallery();
                    if (image == null) return;
                    if (!mounted) return;
                    setState(() {
                      imageFile = image;
                    });
                    Navigator.pop(ctx);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: const [
                        SizedBox(width: 10),
                        Icon(Iconsax.gallery),
                        SizedBox(width: 15),
                        Text(
                          "Choose from library",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final image = await imageChooser.getFromCamera();
                    if (image == null) return;
                    if (!mounted) return;
                    setState(() {
                      imageFile = image;
                    });
                    Navigator.pop(ctx);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: const [
                        SizedBox(width: 10),
                        Icon(Iconsax.camera),
                        SizedBox(width: 15),
                        Text(
                          "Take Photo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
