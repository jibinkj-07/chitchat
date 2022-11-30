import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:chitchat/widgets/chat/imageMessage_preview.dart';
import 'package:chitchat/widgets/general/message_bubble_functions.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/custom_shape.dart';
import 'dart:developer' as dev;

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

    //TEXT MESSAGE
    var textMessage = GestureDetector(
      onLongPress: () {
        MessageBubbleFunctions().showBottom(context, messageItem);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          messageItem.message,
          style: TextStyle(
            color: Colors.black,
            fontSize: EmojiUtil.hasOnlyEmojis(messageItem.message) ? 30 : 15,
          ),
        ),
        const SizedBox(height: 5),
        //time
        Text(
          messageTime,
          style: TextStyle(
            color: Colors.black.withOpacity(.9),
            fontSize: 10,
          ),
        ),
      ]),
    );

//IMAGE MESSAGE
    var imageMessage = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //image preview
        Container(
          width: 220,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.black,
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
                    const Text(
                      'sending',
                      style: TextStyle(
                        color: Colors.black,
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
                            id: messageItem.messageId),
                      ),
                    );
                  },
                  onLongPress: () {
                    MessageBubbleFunctions().showBottom(context, messageItem);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: CachedNetworkImage(
                      imageUrl: messageItem.message,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CupertinoActivityIndicator(
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
            color: Colors.black.withOpacity(.9),
            fontSize: 10,
          ),
        ),
      ],
    );

//main
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        left: 2.0,
        right: 50,
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
                    painter: CustomShape(Colors.grey[300]!),
                    size: const Size(8, 10),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child:
                        messageItem.type == 'text' ? textMessage : imageMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
