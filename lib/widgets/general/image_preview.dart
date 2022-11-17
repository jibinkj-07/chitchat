import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';

class ImagePreview extends StatefulWidget {
  final String url;
  final String id;
  final String title;
  final bool isEditable;

  const ImagePreview({
    super.key,
    required this.url,
    required this.title,
    required this.id,
    required this.isEditable,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  File? updatedImage;
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    FirebaseOperations firebaseOperations = FirebaseOperations();

    /// Get from gallery
    getFromGallery() async {
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
      );
      if (pickedFile != null) {
        // firebaseOperations.updateImage(
        //     image: File(pickedFile.path), id: widget.id, context: context);
        if (!mounted) return;
        setState(() {
          updatedImage = File(pickedFile.path);
        });
      }
    }

    /// Get from Camera
    getFromCamera() async {
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
      );
      if (pickedFile != null) {
        // firebaseOperations.updateImage(
        //     image: File(pickedFile.path), id: widget.id, context: context);
        if (!mounted) return;
        setState(() {
          updatedImage = File(pickedFile.path);
        });
      }
    }

    void changeProfilePicture(BuildContext ctx) {
      showCupertinoModalPopup<void>(
        context: ctx,
        builder: (BuildContext ctx) => CupertinoActionSheet(
          actions: <CupertinoActionSheetAction>[
            if (widget.url != '')
              CupertinoActionSheetAction(
                /// This parameter indicates the action would be a default
                /// defualt behavior, turns the action's text to bold text.
                onPressed: () {
                  // firebaseOperations.deleteImage(
                  //     id: widget.id, context: context);
                  Navigator.pop(ctx);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: appColors.redColor,
                  ),
                ),
              ),
            CupertinoActionSheetAction(
              /// This parameter indicates the action would be a default
              /// defualt behavior, turns the action's text to bold text.

              onPressed: () {
                getFromCamera();
                Navigator.pop(ctx);
              },
              child: const Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                getFromGallery();
                Navigator.pop(ctx);
              },
              child: const Text(
                'Choose Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                // fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors().primaryColor,
              ),
            ),
          ),
        ),
      );
    }

    if (updatedImage != null) {
      Future.delayed(const Duration(seconds: 9)).then(
        (_) => Navigator.of(context).pop(),
      );
    }

    //main
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: appColors.primaryColor,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: appColors.primaryColor,
          splashRadius: 20.0,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          widget.isEditable
              ? TextButton(
                  onPressed: () {
                    changeProfilePicture(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'edit',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              : const SizedBox()
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: updatedImage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/illustrations/progress_indicator.svg',
                  ),
                  const Text("Updating image"),
                  const SizedBox(height: 10),
                  LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width,
                    animation: true,
                    lineHeight: 8.0,
                    animationDuration: 8000,
                    percent: 1,
                    barRadius: const Radius.circular(20),
                    curve: Curves.slowMiddle,
                    progressColor: AppColors().primaryColor,
                  ),
                ],
              )
            : InteractiveViewer(
                child: Hero(
                  tag: widget.id,
                  child: widget.url == ''
                      ? Image.asset('assets/images/profile_dark.png')
                      : Image.network(widget.url, fit: BoxFit.contain),
                ),
              ),
      ),
    );
  }
}
