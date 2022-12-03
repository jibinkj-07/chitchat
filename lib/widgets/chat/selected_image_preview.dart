import 'dart:io';
import 'package:chitchat/logic/database/firebase_chat_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';

class SelectedImagePreview extends StatefulWidget {
  const SelectedImagePreview({
    Key? key,
    required this.imageFile,
    required this.targetUserid,
    required this.currentUserid,
    required this.parentContext,
  }) : super(key: key);

  final Future<File?> imageFile;
  final String currentUserid;
  final String targetUserid;
  final BuildContext parentContext;

  @override
  State<SelectedImagePreview> createState() => _SelectedImagePreviewState();
}

class _SelectedImagePreviewState extends State<SelectedImagePreview> {
  File? sendingImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            //image preview
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: sendingImage == null
                  ? imagePreview()
                  : InteractiveViewer(
                      child: Image.file(
                        sendingImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),

            //top bar
            if (sendingImage != null)
              topBar(
                appColors: appColors,
                context: context,
              ),

            //send button
            Positioned(
              bottom: 20,
              right: 20,
              child: sendButton(appColors: appColors, context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePreview() => FutureBuilder<File?>(
        future: widget.imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;

          if (snapshot.connectionState == ConnectionState.done) {
            if (file == null) {
              return const Text(
                'Error',
                style: TextStyle(
                  color: Colors.white,
                ),
              );
            } else {
              Future.delayed(Duration.zero, () {
                setState(() {
                  sendingImage = snapshot.data;
                });
              });
              return InteractiveViewer(
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                ),
              );
            }
          }
          return CircularProgressIndicator(
            strokeWidth: 1.5,
            backgroundColor: Colors.white,
            color: AppColors().primaryColor,
          );
        },
      );

  Widget sendButton(
          {required AppColors appColors, required BuildContext context}) =>
      FloatingActionButton(
        onPressed: () async {
          final nav1 = Navigator.of(context);
          final nav2 = Navigator.of(widget.parentContext);
          await FirebaseChatOperations().sendImage(
              senderId: widget.currentUserid,
              targetId: widget.targetUserid,
              image: sendingImage!);
          //closing both pages
          nav1.pop();
          nav2.pop();
        },
        backgroundColor: appColors.primaryColor,
        child: const Icon(Iconsax.send_1),
      );

  //CROPPING IMAGE
  Future<void> cropImage(File image) async {
    ImageCropper imageCropper = ImageCropper();
    AppColors appColors = AppColors();
    final result = await imageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Edit image',
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
        sendingImage = File(result.path);
      });
    }
  }

  Widget topBar({
    required AppColors appColors,
    required BuildContext context,
  }) =>
      Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: appColors.primaryColor,
              borderRadius: BorderRadius.circular(40),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: appColors.textColorWhite,
                  splashRadius: 20.0,
                  iconSize: 20.0,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Material(
              color: appColors.primaryColor,
              borderRadius: BorderRadius.circular(40),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(Icons.crop),
                  color: appColors.textColorWhite,
                  splashRadius: 20.0,
                  iconSize: 20.0,
                  onPressed: () {
                    cropImage(sendingImage!);
                  },
                ),
              ),
            ),
          ],
        ),
      );
}
