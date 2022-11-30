import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:chitchat/widgets/chat/image_reply_message_identifier.dart';
import 'package:chitchat/widgets/chat/text_reply_message_identifier.dart';
import 'package:chitchat/widgets/general/message_bubble_functions.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/custom_shape.dart';
import 'imageMessage_preview.dart';

class SendMessageBubble extends StatelessWidget {
  final MessageItem messageItem;
  final String messageTime;
  const SendMessageBubble({
    Key? key,
    required this.messageItem,
    required this.messageTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();

//TEXT MESSAGE
    var textMessage = GestureDetector(
      onLongPress: () =>
          MessageBubbleFunctions().showBottom(context, messageItem),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          if (messageItem.isReplied)
            messageItem.repliedToMessage
                    .toLowerCase()
                    .contains('https://firebasestorage.googleapis.com')
                ? ImageReplyMessageIdentifier(
                    messageItem: messageItem,
                    appColors: appColors,
                  )
                : TextReplyMessageIdentifier(
                    messageItem: messageItem,
                    appColors: appColors,
                  ),
          SizedBox(
            width: messageItem.isReplied ? double.infinity : null,
            child: Text(
              '${messageItem.message}   ',
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    EmojiUtil.hasOnlyEmojis(messageItem.message) ? 30 : 15,
              ),
              textAlign: TextAlign.left,
            ),
          ),

          //time and read status

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$messageTime  ',
                style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontSize: 11,
                ),
              ),
              if (messageItem.read)
                const Text(
                  'read',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
            ],
          )
        ],
      ),
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
            color: Colors.white,
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
        //time and read status
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$messageTime  ',
              style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontSize: 11,
              ),
            ),
            if (messageItem.read)
              const Text(
                'seen',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ],
    );

    //main
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        right: 2.0,
        left: 100,
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: appColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child:
                        messageItem.type == 'text' ? textMessage : imageMessage,
                  ),
                ),
                CustomPaint(
                  painter: CustomShape(appColors.primaryColor),
                  size: const Size(8, 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
