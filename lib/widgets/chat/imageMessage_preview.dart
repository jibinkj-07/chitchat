import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iconsax/iconsax.dart';

class ImageMessagePreview extends StatefulWidget {
  final String url;
  final String id;
  const ImageMessagePreview({
    super.key,
    required this.url,
    required this.id,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                  ),
                  splashRadius: 20.0,
                  iconSize: 20.0,
                  color: Colors.white,
                ),

                //download Button
                IconButton(
                  onPressed: () async {
                    final imageName = 'chitchatImage_${widget.id}.jpeg';
                    await saveImage(widget.url, imageName);
                  },
                  icon: const Icon(Iconsax.import),
                  splashRadius: 20.0,
                  iconSize: 25.0,
                  color: Colors.white,
                )
              ],
            ),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const CupertinoAlertDialog(
        title: Text('Saving image'),
        content: CupertinoActivityIndicator(
          radius: 15,
          color: Colors.black,
        ),
      ),
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
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath = "$newPath/Chitchat";
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
