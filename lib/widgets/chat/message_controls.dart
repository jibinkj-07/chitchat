import 'dart:developer';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/app_colors.dart';

class MessageControls extends StatefulWidget {
  final String targetUserid;
  final String currentUserid;
  const MessageControls({
    super.key,
    required this.targetUserid,
    required this.currentUserid,
  });

  @override
  State<MessageControls> createState() => _MessageControlsState();
}

class _MessageControlsState extends State<MessageControls> {
  TextEditingController messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String message = '';
  bool isEmojiPicker = false;

  @override
  void initState() {
    focusNode.addListener(() async {
      if (focusNode.hasFocus) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          isEmojiPicker = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (isEmojiPicker) {
          setState(() {
            isEmojiPicker = false;
          });
          return false;
        }
        return true;
      },
      child: Column(
        children: [
          //MESSAGE CONTROLLER SECTION
          Container(
            width: screen.width,
            margin: const EdgeInsets.only(bottom: 5.0),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //message controller
                Expanded(
                    child: messageContainer(
                        controller: messageController, appColors: appColors)),

                const SizedBox(width: 10),

                //send button
                message.isEmpty
                    ? micButton(appColors: appColors)
                    : sendButton(appColors: appColors),
              ],
            ),
          ),

          //SMILEY KEYBOARD SECTION
          if (isEmojiPicker)
            emojiKeyboard(appColors: appColors, controller: messageController),
        ],
      ),
    );
  }

  Widget messageContainer({
    required TextEditingController controller,
    required AppColors appColors,
  }) =>
      Material(
        color: appColors.textColorWhite,
        borderRadius: BorderRadius.circular(30.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //smiley iconbutton
            isEmojiPicker
                ? keyboardButton(appColors: appColors)
                : smileyButton(appColors: appColors),

            //textField
            Expanded(
              child: textField(
                controller: controller,
                appColors: appColors,
              ),
            ),

            //image button
            if (message.isEmpty) imageButton(appColors: appColors),

            //camera button
            if (message.isEmpty) cameraButton(appColors: appColors),
          ],
        ),
      );

  Widget sendButton({required AppColors appColors}) => SizedBox(
        height: 50,
        width: 50,
        child: FloatingActionButton(
          backgroundColor: appColors.primaryColor,
          foregroundColor: Colors.white,
          onPressed: () {},
          child: const Icon(
            Iconsax.send_1,
            size: 25,
          ),
        ),
      );

  Widget micButton({required AppColors appColors}) => SizedBox(
        height: 50,
        width: 50,
        child: FloatingActionButton(
          backgroundColor: appColors.primaryColor,
          foregroundColor: Colors.white,
          onPressed: () {},
          child: const Icon(
            Iconsax.microphone,
            size: 25,
          ),
        ),
      );

  Widget emojiKeyboard(
          {required AppColors appColors,
          required TextEditingController controller}) =>
      SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (Category? category, Emoji emoji) {
            setState(() {
              message = '$message${emoji.emoji}';
            });
          },
          onBackspacePressed: () {
            if (message.isNotEmpty) {
              final input = message.characters.skipLast(1);
              setState(() {
                message = input.toString();
              });
            }
          },
          textEditingController: controller,
          config: Config(
            columns: 8,
            emojiSizeMax: 32.0,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: appColors.textColorWhite,
            indicatorColor: appColors.primaryColor,
            iconColor: Colors.grey,
            iconColorSelected: appColors.primaryColor,
            backspaceColor: appColors.primaryColor,
            skinToneDialogBgColor: appColors.textColorWhite,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            showRecentsTab: true,
            recentsLimit: 28,
            noRecents: Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: appColors.textColorBlack),
              textAlign: TextAlign.center,
            ), // Needs to be const Widget
            loadingIndicator:
                const SizedBox.shrink(), // Needs to be const Widget
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
          ),
        ),
      );
  //smiley button
  Widget smileyButton({required AppColors appColors}) => IconButton(
        onPressed: () async {
          if (focusNode.hasFocus) {
            focusNode.unfocus();
          }
          await Future.delayed(const Duration(milliseconds: 100));
          setState(
            () {
              isEmojiPicker = true;
            },
          );
        },
        icon: const Icon(Iconsax.happyemoji5),
        color: appColors.primaryColor,
        splashRadius: 18.0,
        iconSize: 22.0,
        splashColor: appColors.primaryColor.withOpacity(.2),
      );

  //keyboard button
  Widget keyboardButton({required AppColors appColors}) => IconButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(focusNode);
        },
        icon: const Icon(Iconsax.keyboard5),
        color: appColors.primaryColor,
        splashRadius: 18.0,
        iconSize: 22.0,
        splashColor: appColors.primaryColor.withOpacity(.2),
      );

  //Textfield
  Widget textField({
    required TextEditingController controller,
    required AppColors appColors,
  }) =>
      CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        minLines: 1,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        placeholder: "Type message",
        onChanged: (value) {
          setState(() {
            message = value.trim();
          });
        },
        clearButtonMode: OverlayVisibilityMode.editing,
        cursorColor: appColors.primaryColor,
        decoration: const BoxDecoration(),
      );

  //Image button
  Widget imageButton({required AppColors appColors}) => IconButton(
        onPressed: () {},
        icon: const Icon(Iconsax.gallery5),
        color: appColors.primaryColor,
        splashRadius: 18.0,
        iconSize: 22.0,
        splashColor: appColors.primaryColor.withOpacity(.2),
      );

  //camera button
  Widget cameraButton({required AppColors appColors}) => IconButton(
        onPressed: () {},
        icon: const Icon(Iconsax.camera5),
        color: appColors.primaryColor,
        splashRadius: 18.0,
        iconSize: 22.0,
        splashColor: appColors.primaryColor.withOpacity(.2),
      );
}
