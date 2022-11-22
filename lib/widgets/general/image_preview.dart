import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/screens/setting_screen.dart';
import 'package:chitchat/utils/image_chooser.dart';
import 'package:chitchat/widgets/general/image_updating.dart';
import 'package:chitchat/widgets/settings/user_settings.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
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
      ImageChooser imageChooser = ImageChooser();
      showModalBottomSheet<void>(
        context: context,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: const [
                          SizedBox(width: 10),
                          Icon(Iconsax.gallery),
                          SizedBox(width: 15),
                          Text(
                            "Choose from library",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
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
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: const [
                          SizedBox(width: 10),
                          Icon(Iconsax.camera),
                          SizedBox(width: 15),
                          Text(
                            "Take photo",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.url != '')
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(ctx);
                        showAlertDialog(context);
                        await firebaseOperations.deleteImage(
                            id: widget.id, context: context);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(
                              Iconsax.trash,
                              color: appColors.redColor,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "Remove current photo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: appColors.redColor,
                              ),
                            ),
                          ],
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

    //main
    return updatedImage == null
        ? Scaffold(
            body: SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: Colors.black,
                          splashRadius: 20.0,
                          iconSize: 20.0,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.isEditable
                              ? () {
                                  changeProfilePicture(context);
                                }
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: appColors.primaryColor,
                            disabledForegroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              // fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                    const Divider(
                      height: 0,
                    ),
                    Expanded(
                      child: InteractiveViewer(
                        child: Hero(
                          tag: widget.id,
                          child: widget.url == ''
                              ? Image.asset('assets/images/profile.png')
                              : CachedNetworkImage(
                                  imageUrl: widget.url,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      CupertinoActivityIndicator(
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
                    ),
                  ],
                ),
              ),
            ),
          )
        : ImageUpdating(
            image: updatedImage,
          );
  }
}