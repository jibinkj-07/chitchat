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
    FirebaseOperations firebaseOperations = FirebaseOperations();
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // color: Colors.black,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              // height: 40,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 1, color: Colors.grey),
                ),
              ),
            ),
          ),

          //control buttons
          _msg.trim() == ''
              ? controlButton(appColors)
              : IconButton(
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
                  icon: const Icon(
                    Iconsax.send_1,
                    size: 25,
                  ),
                  splashRadius: 20,
                  splashColor: appColors.primaryColor.withOpacity(.3),
                  color: appColors.primaryColor,
                )
        ],
      ),
    );
  }

  Widget controlButton(AppColors appColors) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Iconsax.camera,
              size: 25,
            ),
            splashRadius: 20,
            splashColor: appColors.primaryColor.withOpacity(.3),
            color: appColors.primaryColor,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Iconsax.document_text_1,
              size: 25,
            ),
            splashRadius: 20,
            splashColor: appColors.primaryColor.withOpacity(.3),
            color: appColors.primaryColor,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Iconsax.microphone,
              size: 25,
            ),
            splashRadius: 20,
            splashColor: appColors.primaryColor.withOpacity(.3),
            color: appColors.primaryColor,
          ),
        ],
      );
}
