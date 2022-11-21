import 'dart:io';
import 'package:chitchat/screens/setting_screen.dart';
import 'package:chitchat/utils/image_chooser.dart';
import 'package:chitchat/widgets/general/image_updating.dart';
import 'package:chitchat/widgets/settings/user_settings.dart';
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
    ImageChooser imageChooser = ImageChooser();
    // This shows a CupertinoModalPopup which hosts a CupertinoAlertDialog.
    void showAlertDialog(BuildContext context) {
      showCupertinoModalPopup<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => const CupertinoAlertDialog(
          title: Text('Removing'),
          content: CupertinoActivityIndicator(
            radius: 15,
            color: Colors.black,
          ),
        ),
      );
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
                onPressed: () async {
                  Navigator.pop(ctx);
                  showAlertDialog(context);
                  await firebaseOperations.deleteImage(
                      id: widget.id, context: context);
                  if (!mounted) return;
                  Navigator.of(context).pop();
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

              onPressed: () async {
                final image = await imageChooser.getFromCamera();
                if (image == null) return;

                //moving to updating page
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() {
                  updatedImage = image;
                });
                await firebaseOperations.updateImage(
                    image: image, id: widget.id);
                if (!mounted) return;
                Navigator.of(context).pop();
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
              onPressed: () async {
                final image = await imageChooser.getFromGallery();
                if (image == null) return;

                //moving to updating page
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() {
                  updatedImage = image;
                });
                await firebaseOperations.updateImage(
                    image: image, id: widget.id);
                if (!mounted) return;
                Navigator.of(context).pop();
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

    //main
    return updatedImage == null
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: appColors.primaryColor,
              title: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: appColors.primaryColor,
                splashRadius: 20.0,
                iconSize: 20.0,
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
                            // fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InteractiveViewer(
                child: Hero(
                  tag: widget.id,
                  child: widget.url == ''
                      ? Image.asset('assets/images/profile.png')
                      : Image.network(widget.url, fit: BoxFit.contain),
                ),
              ),
            ),
          )
        : ImageUpdating(
            image: updatedImage,
          );
  }
}
