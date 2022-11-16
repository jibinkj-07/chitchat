import 'dart:developer';
import 'dart:io';

import 'package:chitchat/logic/cubit/user_detail_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
              'email': email,
              'imageUrl': url,
              'bio': 'Hey want to chat? ping me',
              'created': DateTime.now(),
            },
            SetOptions(merge: true),
          );
          //Updating bloc
          userCubit.userAuthenticated(
              email: email,
              id: value.user!.uid,
              userName: name,
              imageUrl: url,
              bio: 'Hey want to chat? ping me');
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
            'email': email,
            'imageUrl': '',
            'bio': 'Hey want to chat? ping me',
            'created': DateTime.now(),
          },
          SetOptions(merge: true),
        );
        //Updating bloc
        userCubit.userAuthenticated(
            email: email,
            id: value.user!.uid,
            userName: name,
            imageUrl: '',
            bio: 'Hey want to chat? ping me');
        //ROUTING USER TO HOMEPAGE
        Future.delayed(const Duration(seconds: 2), () {
          navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
        });
      }
    });
  }

//USER LOGIN METHOD
  //method to create new account
  Future<void> loginUser({
    required String email,
    required String password,
    required String name,
    required String id,
    required String bio,
    required String imageUrl,
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        context.read<UserDetailCubit>().userAuthenticated(
              userName: name,
              imageUrl: imageUrl,
              id: id,
              email: email,
              bio: bio,
            );
        //ROUTING USER TO HOMEPAGE
        Future.delayed(const Duration(seconds: 1), () {
          navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
        });
      });
    } catch (e) {
      log('${e.toString()}');
      if (e.toString().contains('unusual activity')) {
        ScaffoldMessenger.of(context).showSnackBar(
            snackBar(message: 'Too many attempts found. Try again later'));
      } else if (e.toString().contains('wrong-password')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar(message: 'Invalid password! Try again'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            snackBar(message: 'Something went wrong. Try again later.'));
      }
    }
  }

  SnackBar snackBar({required String message}) {
    return SnackBar(
      backgroundColor: AppColors().primaryColor,
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
    );
  }

  //method to get user details in login page
  Future<Map<String, String>> getLoginUserDetails(
      {required String email}) async {
    final id = await getUseridFromEmail(email: email);
    Map<String, String> data = await getUserDetails(userId: id);
    return data;
  }

//retrieving user id from user email
  Future<String> getUseridFromEmail({required String email}) async {
    String id = '';
    await database.get().then((snapshot) {
      final result =
          snapshot.docs.firstWhere((element) => element.get('email') == email);
      id = result.id.toString().trim();
    });
    return id;
  }

  //getting single user details
  Future<Map<String, String>> getUserDetails({required String userId}) async {
    Map<String, String> details = {};
    await database.doc(userId).get().then((snapshot) {
      details = {
        'id': snapshot.id,
        'name': snapshot.get('name'),
        'email': snapshot.get('email'),
        'imageUrl': snapshot.get('imageUrl'),
        'bio': snapshot.get('bio'),
      };
    });
    return details;
  }
}
