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
  TextEditingController userNameController = TextEditingController();
  bool isVisible = false;
  bool isLoading = false;
  bool isUsernameExist = false;
  File? imageFile;

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

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
    String userName = '';

    //submitting password
    void createAccount() async {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid && !isUsernameExist) {
        setState(() {
          isLoading = true;
        });
        formKey.currentState!.save();
        bool result = await firebaseOperations.createNewUser(
          email: userEmail,
          password: password,
          name: name,
          context: context,
          userImage: imageFile,
          username: userName,
        );
        log('value of result is in sign up is $result');
        if (!result) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }

    void checkUserNameAvailability(String data) async {
      bool result = await firebaseOperations.checkForUsername(username: data);
      log('Value odf result $result');
      if (result) {
        if (!mounted) return;
        setState(() {
          isUsernameExist = true;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isUsernameExist = false;
        });
      }
    }

    //main section
    return Scaffold(
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
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
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
                                  //username
                                  //user name field
                                  SizedBox(
                                    width: screen.width * .8,
                                    child: TextFormField(
                                      cursorColor: appColors.primaryColor,
                                      key: const ValueKey('username'),
                                      textInputAction: TextInputAction.next,
                                      maxLength: 15,

                                      textCapitalization:
                                          TextCapitalization.none,
                                      //validator
                                      validator: (data) {
                                        if (data!.trim().isEmpty) {
                                          return 'Username is empty';
                                        } else if (data.trim().length < 4) {
                                          return 'Username contain atleast 4 letters';
                                        } else if (data.trim().contains(' ')) {
                                          return 'No whitespace are allowed';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        userName = value.toString().trim();
                                      },
                                      onChanged: ((value) {
                                        checkUserNameAvailability(value.trim());
                                      }),
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),

                                      //decoration
                                      decoration: InputDecoration(
                                        counter: const SizedBox(),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 15),
                                        hintText: 'Username',
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
                                  if (isUsernameExist)
                                    Text(
                                      "Username is already exist. Try another one!",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                        color: appColors.redColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                  const SizedBox(height: 8),
                                  //profile name field
                                  SizedBox(
                                    width: screen.width * .8,
                                    child: TextFormField(
                                      cursorColor: appColors.primaryColor,
                                      key: const ValueKey('name'),
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      //validator
                                      validator: (data) {
                                        if (data!.trim().isEmpty) {
                                          return 'Profile name is empty';
                                        }
                                        return null;
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
                                        hintText: 'Profile name',
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
                                                  appColors.textColorWhite,
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
                            const SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Iconsax.information,
                                  size: 15,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Username must be unique and it cannot be edited later. eg:abr_2345',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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

  void changeProfilePicture() {
    ImageChooser imageChooser = ImageChooser();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          // height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 5),
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
