import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

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

    //delete account
    Future<void> deleteAccount() async {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        formKey.currentState!.save();

        FirebaseOperations().deleteAccount(
          email: widget.currentEmail,
          password: password,
          context: context,
          id: widget.id,
        );
      }
    }

    //main
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SafeArea(
          child: Column(
            children: [
              //top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.black,
                    splashRadius: 20.0,
                    iconSize: 20.0,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.transparent,
                    ),
                    color: Colors.white,
                    splashRadius: 20.0,
                    iconSize: 20.0,
                    onPressed: null,
                  ),
                ],
              ),
              const Divider(
                height: 0,
              ),
              const SizedBox(height: 5),
              CircleAvatar(
                radius: 45,
                backgroundColor: appColors.redColor.withOpacity(.2),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: appColors.redColor,
                  child: const Icon(
                    Iconsax.user_remove,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              //body
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: screen.width,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Iconsax.information,
                                size: 15,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Deleting account will remove your Personal information, Chat details,Messages permanently from Chitchat",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
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
                                      return 'Enter your password';
                                    } else if (data.length < 6) {
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
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
                        BlocBuilder<InternetCubit, InternetState>(
                          builder: (context, state) {
                            if (state is InternetEnabled) {
                              return SizedBox(
                                width: screen.width * .5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appColors.redColor,
                                    foregroundColor: appColors.textLightColor,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
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
                              );
                            } else {
                              return const Text(
                                "Turn on Mobile data or Wifi to continue",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                          },
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
