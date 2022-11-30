import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../logic/database/firebase_operations.dart';
import '../../utils/app_colors.dart';

class MessageBubbleFunctions {
  //bottom sheet
  Future<void> showBottom(BuildContext ctx, MessageItem messageItem) async {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();
    await showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: messageItem.type.toLowerCase() == 'image'
                    ? Container(
                        height: 100,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: .5,
                            color: Colors.grey.withOpacity(.4),
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: CachedNetworkImage(
                            imageUrl: messageItem.message,
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
                      )
                    : messageItem.message.length > 30
                        ? Text(
                            '"${messageItem.message.substring(0, 28)}..."',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            '"${messageItem.message}"',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
              if (messageItem.isMe)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      firebaseOperations.deleteMessageForAll(
                          messageId: messageItem.messageId,
                          type: messageItem.type,
                          senderId: messageItem.currentUserid,
                          targetId: messageItem.targetUserid);
                      Navigator.of(ctx).pop(true);
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      // height: 50,
                      width: double.infinity,
                      child: Text(
                        "Delete for all",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: appColors.redColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    firebaseOperations.deleteMessageForMe(
                      messageId: messageItem.messageId,
                      senderId: messageItem.currentUserid,
                      type: messageItem.type,
                      targetId: messageItem.targetUserid,
                      message: 'Message deleted for you',
                    );
                    Navigator.of(ctx).pop(true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    width: double.infinity,
                    child: Text(
                      "Delete for me",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.redColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              //cancel button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: double.infinity,
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appColors.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
