import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ImagePreviewer extends StatelessWidget {
  const ImagePreviewer({
    super.key,
    required this.targetUserid,
    required this.width,
    required this.height,
    required this.url,
  });
  final String url;
  final String targetUserid;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return url == ''
        ? Hero(
            tag: targetUserid,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: .5,
                  color: appColors.textColorBlack.withOpacity(.5),
                ),
                color: appColors.textColorWhite,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Hero(
            tag: targetUserid,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: .5,
                  color: appColors.textColorBlack.withOpacity(.5),
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
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
          );
  }
}
