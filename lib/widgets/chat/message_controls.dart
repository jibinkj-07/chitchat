import 'dart:developer';

import 'package:chitchat/logic/cubit/replying_message_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class MessageControls extends StatefulWidget {
  const MessageControls({
    Key? key,
    required this.senderId,
    required this.targetId,
  }) : super(key: key);
  final String senderId;
  final String targetId;

  @override
  State<MessageControls> createState() => _MessageControlsState();
}

class _MessageControlsState extends State<MessageControls> {
  TextEditingController controller = TextEditingController();
  String _msg = '';
  bool isEmojiPicker = false;
  FocusNode focusNode = FocusNode();

  // @override
  // void initState() {
  //   FocusScope.of(context).addListener(
  //     () {
  //       if (FocusScope.of(context).hasFocus) {
  //         setState(() {
  //           isEmojiPicker = false;
  //         });
  //       }
  //     },
  //   );
  //   super.initState();
  // }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();

    if (FocusScope.of(context).hasFocus) {
      setState(() {
        isEmojiPicker = false;
      });
    }
    // log('message is $_msg');
    return BlocBuilder<ReplyingMessageCubit, ReplyingMessageState>(
      builder: (ctx, state) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8, top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.isReplying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: appColors.primaryColor.withOpacity(.2),
                      ),
                      child: state.message.length > 30
                          ? Text(
                              'Replying to "${state.message.substring(0, 27)}..."',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            )
                          : Text(
                              'Replying to "${state.message}"',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),

                    //button
                    IconButton(
                      onPressed: () {
                        context.read<ReplyingMessageCubit>().clearMessage();
                      },
                      icon: const Icon(Iconsax.close_circle),
                      iconSize: 20,
                      color: appColors.redColor,
                      splashRadius: 20.0,
                    )
                  ],
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey.withOpacity(.2),
                      ),
                      child: Row(
                        crossAxisAlignment: _msg.toString().contains('\n')
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.center,
                        children: [
                          //emoji icon button
                          if (!isEmojiPicker)
                            SizedBox(
                              height: 25,
                              width: 25,
                              child: IconButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  await Future.delayed(
                                    const Duration(milliseconds: 150),
                                  );
                                  setState(() {
                                    isEmojiPicker = !isEmojiPicker;
                                  });
                                  //emoji picker
                                },
                                padding: const EdgeInsets.all(0.0),
                                icon: const Icon(Iconsax.happyemoji),
                                color: appColors.primaryColor,
                                iconSize: 20,
                                splashRadius: 15.0,
                              ),
                            ),

                          //textfield
                          Expanded(
                            child: CupertinoTextField(
                              controller: controller,
                              autofocus: true,
                              // focusNode: focusNode,
                              minLines: 1,
                              maxLines: 5,
                              textCapitalization: TextCapitalization.sentences,
                              placeholder: "Type message",
                              onChanged: (value) {
                                setState(() {
                                  _msg = value;
                                });
                              },
                              clearButtonMode: OverlayVisibilityMode.editing,
                              cursorColor: appColors.primaryColor,
                              decoration: const BoxDecoration(),
                            ),
                          ),

                          //camera button
                          _msg.trim() == ''
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: IconButton(
                                    onPressed: () {},
                                    padding: const EdgeInsets.all(0.0),
                                    icon: const Icon(Iconsax.camera),
                                    color: appColors.primaryColor,
                                    iconSize: 20,
                                    splashRadius: 15.0,
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  _msg.trim() == ''
                      ? FloatingActionButton(
                          backgroundColor: appColors.primaryColor,
                          foregroundColor: Colors.white,
                          mini: true,
                          onPressed: () {},
                          child: const Icon(
                            Iconsax.microphone,
                            size: 22,
                          ),
                        )
                      : FloatingActionButton(
                          backgroundColor: appColors.primaryColor,
                          foregroundColor: Colors.white,
                          mini: true,
                          onPressed: state.isReplying
                              ? () {
                                  String msg = state.message;
                                  if (state.message.length > 30) {
                                    msg =
                                        '${state.message.substring(0, 28)}...';
                                  }
                                  firebaseOperations.sendMessage(
                                      senderId: widget.senderId,
                                      targetId: widget.targetId,
                                      isReplyingMessage: true,
                                      repliedToMessage: msg,
                                      repliedToMe: state.isMine,
                                      body: _msg.trim());
                                  controller.clear();
                                  context
                                      .read<ReplyingMessageCubit>()
                                      .clearMessage();
                                  setState(() {
                                    _msg = '';
                                  });
                                }
                              : () {
                                  firebaseOperations.sendMessage(
                                      senderId: widget.senderId,
                                      targetId: widget.targetId,
                                      isReplyingMessage: false,
                                      repliedToMessage: '',
                                      repliedToMe: false,
                                      body: _msg.trim());
                                  controller.clear();
                                  setState(() {
                                    _msg = '';
                                  });
                                },
                          child: const Icon(
                            Iconsax.send_1,
                            size: 22,
                          ),
                        )
                ],
              ),
              if (isEmojiPicker)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (Category? category, Emoji emoji) {
                      setState(() {
                        _msg = '$_msg${emoji.emoji}';
                      });
                    },

                    onBackspacePressed: () {
                      if (_msg.isNotEmpty) {
                        final input = _msg.characters.skipLast(1);
                        setState(() {
                          _msg = input.toString();
                        });
                      }
                    },
                    textEditingController:
                        controller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(
                      columns: 8,
                      emojiSizeMax:
                          32.0, // Issue: https://github.com/flutter/flutter/issues/28894
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      gridPadding: EdgeInsets.zero,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFFFFFFFF),
                      indicatorColor: appColors.primaryColor,
                      iconColor: Colors.grey,
                      iconColorSelected: appColors.primaryColor,
                      backspaceColor: appColors.primaryColor,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      showRecentsTab: true,
                      recentsLimit: 28,
                      noRecents: const Text(
                        'No Recents',
                        style: TextStyle(fontSize: 20, color: Colors.black26),
                        textAlign: TextAlign.center,
                      ), // Needs to be const Widget
                      loadingIndicator:
                          const SizedBox.shrink(), // Needs to be const Widget
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
