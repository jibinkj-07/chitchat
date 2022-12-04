import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;
import '../../../utils/app_colors.dart';
import '../../../utils/custom_shape.dart';
import '../../../utils/message_Item.dart';

class RepliedReceivedChatBubble extends StatelessWidget {
  final MessageItem messageItem;
  final String messageTime;
  const RepliedReceivedChatBubble({
    super.key,
    required this.messageItem,
    required this.messageTime,
  });
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();

//calculating message length
    const double baseWidth = 80;
    double width = 0;
    if (messageItem.message.length > 25) {
      width = baseWidth + 200;
    } else {
      width = baseWidth + (messageItem.message.length * 7.5);
    }
    //main
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
                        ? textMessage(appColors: appColors, width: width)
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

  Widget textMessage({required AppColors appColors, required double width}) =>
      InkWell(
        onLongPress: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //replied preview

            messageItem.repliedToMessage
                    .contains('https://firebasestorage.googleapis.com')
                ? imageReplyMessage(appColors: appColors)
                : textReplyMessage(appColors: appColors),
            const SizedBox(height: 5),
            //sent message
            Wrap(
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
                  textAlign: TextAlign.left,
                ),

                //time and read status

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$messageTime  ',
                      style: TextStyle(
                        color: appColors.textColorBlack.withOpacity(.8),
                        fontSize: 11,
                      ),
                    ),
                    if (messageItem.read)
                      const Text(
                        'read',
                        style: TextStyle(
                          color: Colors.lime,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                  ],
                )
              ],
            ),
          ],
        ),
      );

  Widget imageMessage(
          {required BuildContext context, required AppColors appColors}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //image preview
          Container(
            width: 220,
            height: 280,
            decoration: BoxDecoration(
              color: appColors.textColorWhite,
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
                    onTap: () {},
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
          //time and read status
          Text(
            '$messageTime  ',
            style: TextStyle(
              color: appColors.textColorWhite.withOpacity(.8),
              fontSize: 11,
            ),
          ),
        ],
      );

  Widget textReplyMessage({required AppColors appColors}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: messageItem.isRepliedToMyself
                  ? appColors.yellowColor
                  : appColors.textColorBlack,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !messageItem.isRepliedToMyself
                    ? Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.textColorBlack,
                          fontSize: 12,
                        ),
                      )
                    : Text(
                        messageItem.targetUsername,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.yellowColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                        ),
                      ),

                //     ? Text('image')
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    messageItem.repliedToMessage,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack.withOpacity(.6),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );

  Widget imageReplyMessage({required AppColors appColors}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: !messageItem.isRepliedToMyself
                  ? appColors.yellowColor
                  : appColors.textColorBlack,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                messageItem.isRepliedToMyself
                    ? Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.textColorBlack,
                          fontSize: 12,
                        ),
                      )
                    : Text(
                        messageItem.targetUsername,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.yellowColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //image
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: messageItem.repliedToMessage,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      color: appColors.primaryColor,
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: appColors.redColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    //text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.camera5,
                          size: 15,
                          color: appColors.textColorBlack.withOpacity(.8),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Photo',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: appColors.textColorBlack.withOpacity(.8),
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      );
}
