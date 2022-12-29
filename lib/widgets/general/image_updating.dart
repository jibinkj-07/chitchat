import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/app_colors.dart';

class ImageUpdating extends StatelessWidget {
  File? image;
  ImageUpdating({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SizedBox(
            width: screen.width,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Updating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(
                  height: 0,
                ),

                //image
                Expanded(
                  child: SizedBox(
                    width: screen.width,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          width: screen.width * .9,
                          height: screen.height * .4,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              image!,
                              fit: BoxFit.cover,
                              // color: Colors.white.withOpacity(.7),
                              // colorBlendMode: BlendMode.modulate,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors().primaryColor,
                            backgroundColor:
                                AppColors().primaryColor.withOpacity(.2),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Iconsax.information,
                                size: 25,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Please wait, your photo is updating and will automatically move to the Profile screen once complete",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
