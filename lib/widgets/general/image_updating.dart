import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors().primaryColor,
          leading: const Icon(
            Icons.abc,
            color: Colors.white,
          ),
          centerTitle: true,
          elevation: 0,
          title: const Text(
            "Updating image",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(
                radius: 15,
                color: AppColors().primaryColor,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: screen.width,
                height: screen.height * .4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                    // color: Colors.white.withOpacity(.7),
                    // colorBlendMode: BlendMode.modulate,
                  ),
                ),
                // decoration: BoxDecoration(
                //   color: const Color(0xff7c94b6),
                //   borderRadius: BorderRadius.circular(10.0),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
