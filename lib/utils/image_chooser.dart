import 'dart:io';
import 'package:chitchat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageChooser {
  /// Get from gallery
  Future<File?> getFromGallery() async {
    File? imageFile;
    await ImagePicker()
        .pickImage(
      source: ImageSource.gallery,
    )
        .then((pickedImage) async {
      if (pickedImage == null) return;
      await cropSelectedImage(pickedImage.path).then((croppedImage) {
        if (croppedImage == null) return;

        imageFile = File(croppedImage.path);
      });
    });
    return imageFile;
  }

  /// Get from Camera
  Future<File?> getFromCamera() async {
    File? imageFile;
    await ImagePicker()
        .pickImage(
      source: ImageSource.camera,
    )
        .then((pickedImage) async {
      if (pickedImage == null) return;
      await cropSelectedImage(pickedImage.path).then((croppedImage) {
        if (croppedImage == null) return null;
        imageFile = File(croppedImage.path);
      });
    });
    return imageFile;
  }

  /// Pick Image From Gallery and return a File
  Future<File?> cropSelectedImage(String filePath) async {
    ImageCropper imageCropper = ImageCropper();
    AppColors appColors = AppColors();
    return await imageCropper.cropImage(
      sourcePath: filePath,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Adjust image',
        toolbarColor: appColors.primaryColor,
        toolbarWidgetColor: Colors.white,
        backgroundColor: Colors.white,
        activeControlsWidgetColor: Colors.blue,
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
  }
}
