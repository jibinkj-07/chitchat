import 'dart:developer';

import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    FirebaseOperations firebaseOperations = FirebaseOperations();

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 0),
      padding: const EdgeInsets.all(0.0),
      child: Row(
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
                crossAxisAlignment: _msg.contains('\n')
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.center,
                children: [
                  //emoji icon button
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: IconButton(
                      onPressed: () {},
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
                  onPressed: () {
                    firebaseOperations.sendMessage(
                        senderId: widget.senderId,
                        targetId: widget.targetId,
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
    );
  }
}
