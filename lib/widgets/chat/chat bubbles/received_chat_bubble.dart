import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:chitchat/widgets/chat/image_message_preview.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import '../../../utils/custom_shape.dart';

class ReceivedMessageBubble extends StatelessWidget {
  final MessageItem messageItem;

  final String messageTime;
  const ReceivedMessageBubble({
    super.key,
    required this.messageItem,
    required this.messageTime,
  });

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        left: 2.0,
        right: 80,
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: CustomPaint(
                    painter: CustomShape(appColors.textColorWhite),
                    size: const Size(8, 10),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: appColors.textColorWhite,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: messageItem.type == 'text'
                        ? textMessage(appColors: appColors)
                        : imageMessage(appColors: appColors, context: context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget textMessage({required AppColors appColors}) => GestureDetector(
        onLongPress: () {},
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              '${messageItem.message}   ',
              style: TextStyle(
                color: appColors.textColorBlack,
                fontSize:
                    EmojiUtil.hasOnlyEmojis(messageItem.message) ? 30 : 15,
              ),
            ),

            //time
            Text(
              messageTime,
              style: TextStyle(
                color: appColors.textColorBlack.withOpacity(.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );

  Widget imageMessage(
          {required AppColors appColors, required BuildContext context}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //image preview
          Container(
            width: 240,
            height: 280,
            decoration: BoxDecoration(
              color: appColors.textColorBlack,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: messageItem.message == ''
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: appColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'sending',
                        style: TextStyle(
                          color: appColors.textColorBlack,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImageMessagePreview(
                              url: messageItem.message,
                              messageItem: messageItem),
                        ),
                      );
                    },
                    onLongPress: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: CachedNetworkImage(
                        imageUrl: messageItem.message,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CupertinoActivityIndicator(
                          color: appColors.primaryColor,
                          radius: 10,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          color: appColors.redColor,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 5),
          //time
          Text(
            messageTime,
            style: TextStyle(
              color: appColors.textColorBlack.withOpacity(.8),
              fontSize: 11,
            ),
          ),
        ],
      );
}
