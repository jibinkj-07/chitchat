import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_chooser.dart';

class EditProfile extends StatefulWidget {
  final String id;
  final String url;
  final String name;
  final String bio;
  const EditProfile({
    super.key,
    required this.id,
    required this.url,
    required this.name,
    required this.bio,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? updatedImage;
  String editImage = '';
  String name = '';
  String bio = '';
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  @override
  void dispose() {
    nameTextEditingController.dispose();
    bioTextEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    nameTextEditingController.text = widget.name;
    bioTextEditingController.text = widget.bio;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final screen = MediaQuery.of(context).size;
    FirebaseOperations firebaseOperations = FirebaseOperations();

    void showAlertDialog(BuildContext context) {
      showCupertinoModalPopup<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => const CupertinoAlertDialog(
          title: Text('Updating profile'),
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
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      setState(() {
                        editImage = 'image';
                        updatedImage = image;
                      });
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
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      setState(() {
                        updatedImage = image;
                        editImage = 'image';
                      });
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
                if (widget.url != '' && editImage == '')
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          editImage = 'remove';
                        });

                        Navigator.pop(ctx);
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

    Future<void> editProfile() async {
      FocusScope.of(context).unfocus();
      final navigator = Navigator.of(context);
      showAlertDialog(context);
      if (editImage.trim() != '' && editImage.trim().contains('image')) {
        log('image updating');
        await firebaseOperations.updateImage(
            image: updatedImage!, id: widget.id);
      } else if (editImage.trim() != '' &&
          editImage.trim().contains('remove')) {
        log('image deleting');
        await firebaseOperations.deleteImage(id: widget.id);
      }
      //updating name
      if (name.trim() != '' && name.trim() != widget.name) {
        log('name updating');
        await firebaseOperations.updateName(name: name, id: widget.id);
      }
      //updating bio
      if (bio.trim() != '' && bio.trim() != widget.bio) {
        log('bio updating');
        await firebaseOperations.updateBio(bio: bio, id: widget.id);
      }
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeScreen(index: 2),
          ),
          (route) => false);
    }

    //dialog box for no internet warning
    void showAlertDialogForNoInternet(BuildContext context) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Network Error'),
          content:
              const Text('Make sure you have turned on Mobile data or Wifi.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }

    //main
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //top bar
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
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<InternetCubit, InternetState>(
                  builder: (ctx, state) {
                    return TextButton(
                      onPressed: (editImage.trim() == '' &&
                              (name.trim() == '' ||
                                  name.trim() == widget.name) &&
                              (bio.trim() == '' || bio.trim() == widget.bio))
                          ? null
                          : (state is InternetEnabled)
                              ? editProfile
                              : () {
                                  showAlertDialogForNoInternet(context);
                                },
                      style: TextButton.styleFrom(
                        foregroundColor: appColors.primaryColor,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 0),
            //main body
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: screen.width,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          width: screen.width,
                          child: const Text(
                            "Edit picture",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            changeProfilePicture(context);
                          },
                          child: widget.url == '' && editImage == ''
                              ? Container(
                                  width: 150,
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/profile.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              : editImage == 'image'
                                  ? Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: .5,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.file(
                                          updatedImage!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  : editImage == 'remove'
                                      ? Container(
                                          width: 150,
                                          height: 150,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/profile.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: .5,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: widget.url,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          color: appColors
                                                              .primaryColor,
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                color: appColors.redColor,
                                              ),
                                            ),
                                          ),
                                        ),
                        ),

                        const SizedBox(height: 30),
                        //name
                        SizedBox(
                          width: screen.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Edit name",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  cursorColor: appColors.primaryColor,
                                  controller: nameTextEditingController,
                                  key: const ValueKey('username'),
                                  textInputAction: TextInputAction.done,
                                  textCapitalization: TextCapitalization.words,

                                  onChanged: (data) {
                                    setState(() {
                                      name = data.toString().trim();
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),

                                  //decoration
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    hintText: 'Name',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey.withOpacity(.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        width: 1.5,
                                        color: appColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        //bio
                        SizedBox(
                          width: screen.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Edit bio",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  cursorColor: appColors.primaryColor,
                                  controller: bioTextEditingController,
                                  key: const ValueKey('bio'),
                                  textInputAction: TextInputAction.newline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 6,
                                  onChanged: (data) {
                                    setState(() {
                                      bio = data.toString().trim();
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),

                                  //decoration
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    hintText: 'Bio',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey.withOpacity(.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        width: 1.5,
                                        color: appColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
