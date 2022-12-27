import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iconsax/iconsax.dart';

class ImageMessagePreview extends StatefulWidget {
  final String url;
  final MessageItem messageItem;
  const ImageMessagePreview({
    super.key,
    required this.url,
    required this.messageItem,
  });

  @override
  State<ImageMessagePreview> createState() => _ImageMessagePreviewState();
}

class _ImageMessagePreviewState extends State<ImageMessagePreview> {
  final Dio dio = Dio();
  bool downloaded = false;

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: screen.height,
        width: screen.width,
        child: Stack(
          children: [
            SizedBox(
              height: screen.height,
              width: screen.width,
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.url,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    color: appColors.primaryColor,
                    radius: 15,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: appColors.redColor,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: SizedBox(
                width: screen.width,
                child: Material(
                  color: Colors.black.withOpacity(.6),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top,
                      bottom: 5.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                          splashRadius: 20.0,
                          iconSize: 20.0,
                          color: Colors.white,
                        ),

                        //text
                        widget.messageItem.isMe
                            ? const Text(
                                'You',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                            : Text(
                                widget.messageItem.targetUsername,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),

                        //download Button
                        IconButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            final imageName =
                                'chitchatImage_${widget.messageItem.messageId}.jpeg';
                            await saveImage(widget.url, imageName);
                          },
                          icon: const Icon(Iconsax.import),
                          splashRadius: 20.0,
                          iconSize: 25.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (BuildContext ctx1) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 80, vertical: 320),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors().textColorWhite,
                  backgroundColor: AppColors().primaryColor,
                ),
              ),
              Text(
                'Saving image',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors().textColorWhite,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> saveImage(String url, String fileName) async {
    showAlertDialog(context);
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
          String newPath = "";
          // print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath = "$newPath/DCIM/Chitchat";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File("${directory.path}/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(
          url,
          saveFile.path,
        );
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        if (!mounted) return false;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image saved',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
          ),
        );
        return true;
      }
      if (!mounted) return false;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Try again later!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } catch (e) {
      print(e);
      if (!mounted) return false;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Try again later!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
}
