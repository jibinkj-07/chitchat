import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountDeletion extends StatefulWidget {
  final String currentEmail;
  final String id;
  const AccountDeletion(
      {super.key, required this.currentEmail, required this.id});

  @override
  State<AccountDeletion> createState() => _AccountDeletionState();
}

class _AccountDeletionState extends State<AccountDeletion> {
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    String password = '';
    String email = '';

    void showAlertDialog(BuildContext context) {
      showCupertinoModalPopup<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text(
            'Authorization Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'You have no authorization to delete this account.',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              /// This parameter indicates this action is the default,
              /// and turns the action's text to bold text.
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    //delete account
    void deleteAccount() {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        formKey.currentState!.save();
        if (widget.currentEmail != email) {
          showAlertDialog(context);
        } else {
          FirebaseOperations().deleteAccount(
            email: email,
            password: password,
            context: context,
            id: widget.id,
          );
        }
      }
    }

    //main
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: appColors.primaryColor,
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: appColors.primaryColor,
          splashRadius: 20.0,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: SizedBox(
            width: screen.width,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/illustrations/sad.svg',
                  height: screen.height * .3,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Confirm your identity",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      //user email field
                      SizedBox(
                        width: screen.width * .8,
                        child: TextFormField(
                          cursorColor: appColors.primaryColor,
                          key: const ValueKey('email'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          //validator
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
                            hintText: 'Email',
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
                const SizedBox(height: 20),
                //delete button
                SizedBox(
                  width: screen.width * .8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.redColor,
                      foregroundColor: appColors.textLightColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: deleteAccount,
                    child: const Text(
                      "Delete",
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
}
