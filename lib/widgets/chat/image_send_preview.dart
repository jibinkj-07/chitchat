import 'dart:developer';
import 'dart:io';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../utils/app_colors.dart';

class ImageSendPreview extends StatefulWidget {
  final File image;
  final String senderId;
  final String targetId;
  const ImageSendPreview({
    super.key,
    required this.image,
    required this.senderId,
    required this.targetId,
  });

  @override
  State<ImageSendPreview> createState() => _ImageSendPreviewState();
}

class _ImageSendPreviewState extends State<ImageSendPreview> {
  late File choosenImage;

  @override
  void initState() {
    choosenImage = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: SizedBox(
        height: screen.height,
        width: screen.width,
        child: Stack(
          children: [
            SizedBox(
              height: screen.height,
              child: InteractiveViewer(
                child: Image.file(choosenImage),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: screen.width,
                color: Colors.black.withOpacity(.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      splashRadius: 20.0,
                      iconSize: 25.0,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Send image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.crop,
                      ),
                      color: Colors.white,
                      splashRadius: 25.0,
                      iconSize: 20.0,
                      onPressed: () {
                        cropImage(widget.image);
                      },
                    ),
                  ],
                ),
              ),
            ),
            //send button
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  backgroundColor: AppColors().primaryColor,
                  foregroundColor: Colors.white,
                  mini: false,
                  onPressed: () {
                    sendImage(choosenImage);
                  },
                  child: const Icon(
                    Iconsax.send_1,
                    size: 30,
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  Future<void> cropImage(File image) async {
    ImageCropper imageCropper = ImageCropper();
    AppColors appColors = AppColors();
    final result = await imageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Adjust image',
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        backgroundColor: Colors.black,
        activeControlsWidgetColor: appColors.primaryColor,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
      ),
      iosUiSettings: const IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: true,
        minimumAspectRatio: 1.0,
        aspectRatioPickerButtonHidden: true,
      ),
    );
    if (result != null) {
      setState(() {
        choosenImage = File(result.path);
      });
    }
  }

  void sendImage(File choosenImage) {
    var firebaseOperations = FirebaseOperations();
    firebaseOperations.sendImage(
      senderId: widget.senderId,
      targetId: widget.targetId,
      image: choosenImage,
    );
    Navigator.of(context).pop();
  }
}
