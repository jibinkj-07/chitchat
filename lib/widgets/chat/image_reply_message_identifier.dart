import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/app_colors.dart';
import '../../utils/message_Item.dart';

class ImageReplyMessageIdentifier extends StatelessWidget {
  const ImageReplyMessageIdentifier({
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.white.withOpacity(.85),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //title
              Container(
                padding:
                    const EdgeInsets.only(top: 6.0, left: 6.0, bottom: 6.0),
                height: 80,
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
                    Expanded(
                      child: Row(
                        children: const [
                          Icon(
                            Iconsax.camera5,
                            size: 15,
                            color: Colors.black87,
                          ),
                          Text(
                            'Image',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //image
              Container(
                height: 80,
                width: 70,
                decoration: BoxDecoration(
                  border: Border.all(width: .5, color: appColors.primaryColor),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6.0),
                    bottomRight: Radius.circular(6.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6.0),
                    bottomRight: Radius.circular(6.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: messageItem.repliedToMessage,
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
            ],
          )
        ],
      ),
    );
  }
}
