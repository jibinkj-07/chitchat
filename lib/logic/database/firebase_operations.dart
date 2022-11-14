import 'dart:developer';
import 'dart:io';

import 'package:chitchat/logic/cubit/user_detail_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirebaseOperations {
  //Global vairables
  final database = FirebaseFirestore.instance.collection('Users');

  //method to authentication the user
  Future<String> authenticateUser({required String userEmail}) async {
    try {
      final list =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(userEmail);
      if (list.isNotEmpty) {
        return 'true';
      } else {
        return 'false';
      }
    } catch (error) {
      log('Error ${error.toString()}');
      return 'error';
    }
  }

  //method to create new account
  Future<void> createNewUser({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
    File? userImage,
  }) async {
    final userCubit = context.read<UserDetailCubit>();
    final navigator = Navigator.of(context);
    final storageRef = FirebaseStorage.instance.ref().child("Profile Images");
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      //if user have profile image to upload
      if (userImage != null) {
        log('user have image');
        await storageRef
            .child('${value.user!.uid}.jpg')
            .putFile(userImage)
            .whenComplete(() async {
          final url =
              await storageRef.child('${value.user!.uid}.jpg').getDownloadURL();
          database.doc(value.user!.uid).set(
            {
              'name': name,
              'imageUrl': url,
              'created': DateTime.now(),
            },
            SetOptions(merge: true),
          );
          //Updating bloc
          userCubit.userAuthenticated(userName: name, imageUrl: url);
          //ROUTING USER TO HOMEPAGE
          Future.delayed(const Duration(seconds: 3), () {
            navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
          });
        });
      }
      //if user have no profile image
      else {
        log('user not have image');
        database.doc(value.user!.uid).set(
          {
            'name': name,
            'imageUrl': '',
            'created': DateTime.now(),
          },
          SetOptions(merge: true),
        );
        //Updating bloc
        userCubit.userAuthenticated(userName: name, imageUrl: '');
        //ROUTING USER TO HOMEPAGE
        Future.delayed(const Duration(seconds: 2), () {
          navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
        });
      }
    });
  }
}
