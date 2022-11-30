import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/message_Item.dart';

class TextReplyMessageIdentifier extends StatelessWidget {
  const TextReplyMessageIdentifier({
    Key? key,
    required this.messageItem,
    required this.appColors,
  }) : super(key: key);

  final MessageItem messageItem;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.white.withOpacity(.85),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          messageItem.isRepliedToMyself
              ? Text(
                  'You',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: appColors.greenColor,
                  ),
                )
              : Text(
                  overflow: TextOverflow.ellipsis,
                  messageItem.targetUsername,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: appColors.redColor,
                  ),
                ),
          Text(
            messageItem.repliedToMessage,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
