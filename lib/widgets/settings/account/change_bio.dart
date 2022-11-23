import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../logic/cubit/internet_cubit.dart';
import '../../../logic/database/hive_operations.dart';
import '../../../logic/database/user_model.dart';

class ChangeBio extends StatefulWidget {
  const ChangeBio({
    super.key,
  });

  @override
  State<ChangeBio> createState() => _ChangeBioState();
}

class _ChangeBioState extends State<ChangeBio> {
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    String bio = '';
    void showAlertDialog({
      required BuildContext context,
      required String title,
      required String content,
    }) {
      showCupertinoModalPopup<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) => CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              /// This parameter indicates this action is the default,
              /// and turns the action's text to bold text.
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    //delete account
    Future<void> changeBio(String id) async {
      FocusScope.of(context).unfocus();
      final valid = formKey.currentState!.validate();
      if (valid) {
        formKey.currentState!.save();
        bool result = await FirebaseOperations().updateBio(
          bio: bio,
          id: id,
        );
        if (result) {
          showAlertDialog(
            context: context,
            title: "Done",
            content: "Profile bio updated successfully",
          );
        } else {
          showAlertDialog(
            context: context,
            title: "Error",
            content: "Something went wrong. Try again later",
          );
        }
      }
    }

    //main
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: userDetailNotifier,
            builder:
                (BuildContext ctx, List<UserModel> userDetail, Widget? child) {
              return Column(
                children: [
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
                        'Profile Bio',
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
                          "Friends who ever visiting your profile can see your profile bio. Share about yourself,who your are or what you think.",
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: screen.width * .9,
                    child: const Text(
                      "Enter new profile bio",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  //textfield
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        //user email field
                        SizedBox(
                          width: screen.width * .9,
                          child: TextFormField(
                            cursorColor: appColors.primaryColor,
                            key: const ValueKey('bio'),
                            textInputAction: TextInputAction.newline,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 6,
                            // expands: true,
                            //validator
                            validator: (data) {
                              if (data!.isEmpty) {
                                return 'Profile bio is empty';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              bio = value.toString().trim();
                            },
                            style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),

                            //decoration
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              hintText: userDetail[0].bio,
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
                              backgroundColor: appColors.primaryColor,
                              foregroundColor: appColors.textLightColor,
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              changeBio(userDetail[0].id);
                            },
                            child: const Text(
                              "Update",
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
              );
            }),
      ),
    );
  }
}
