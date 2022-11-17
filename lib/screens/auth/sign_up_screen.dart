import 'dart:developer';
import 'dart:io';

import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/image_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    void createAccount() {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        setState(() {
          isLoading = true;
        });
        formKey.currentState!.save();
        firebaseOperations.createNewUser(
          email: userEmail,
          password: password,
          name: name,
          context: context,
          userImage: imageFile,
        );
      }
    }

    //main section
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const IconButton(
          onPressed: null,
          icon: Icon(
            Icons.abc,
            color: Colors.white,
          ),
          color: Colors.white,
        ),
        title: const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            width: screen.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    //Profile picture
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: appColors.primaryColor.withOpacity(.3),
                      child: CircleAvatar(
                        radius: 85,
                        backgroundColor: appColors.primaryColor.withOpacity(.8),
                        child: imageFile == null
                            ? const CircleAvatar(
                                radius: 80,
                                // backgroundColor: Colors.white,
                                backgroundImage: AssetImage(
                                    'assets/images/profile_dark.png'),
                              )
                            : CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                backgroundImage: FileImage(imageFile!),
                              ),
                      ),
                    ),

                    //profile changing button
                    if (!isLoading)
                      IconButton(
                        onPressed: () {
                          changeProfilePicture(context);
                        },
                        color: appColors.primaryColor,
                        icon: const Icon(
                          Iconsax.gallery_edit,
                        ),
                        splashRadius: 20.0,
                      ),
                  ],
                ),

                const SizedBox(height: 8),
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
                          textCapitalization: TextCapitalization.words,
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
                                const EdgeInsets.symmetric(horizontal: 15),
                            hintText: 'Name',
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
                          onPressed: createAccount,
                          child: const Text(
                            "Create",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // This shows a CupertinoModalPopup which hosts a CupertinoActionSheet.
  void changeProfilePicture(BuildContext ctx) {
    ImageChooser imageChooser = ImageChooser();
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup<void>(
      context: ctx,
      builder: (BuildContext ctx) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// defualt behavior, turns the action's text to bold text.

            onPressed: () async {
              final image = await imageChooser.getFromCamera();
              if (image == null) return;
              if (!mounted) return;
              setState(() {
                imageFile = image;
              });
              Navigator.pop(ctx);
            },
            child: const Text(
              'Take Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              final image = await imageChooser.getFromGallery();
              if (image == null) return;
              if (!mounted) return;
              setState(() {
                imageFile = image;
              });
              Navigator.pop(ctx);
            },
            child: const Text(
              'Choose Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Cancel',
            style: TextStyle(
              // fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors().primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
