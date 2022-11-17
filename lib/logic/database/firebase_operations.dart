import 'dart:developer';
import 'dart:io';
import 'package:chitchat/logic/database/hive_operations.dart';
import 'package:chitchat/logic/database/user_model.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirebaseOperations {
//GLOBAL VAIRABLES
  final database = FirebaseFirestore.instance.collection('Users');

//READING ALL USERS
  Future<List<Map<String, dynamic>>> getUsers() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await database.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs
        .map((data) => {
              'id': data.id,
              'name': data.get('name'),
              'email': data.get('email'),
              'imageUrl': data.get('imageUrl'),
              'bio': data.get('bio'),
            })
        .toList();
    return allData;
  }

  //METHOD TO AUTHENTICATION THE USER
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

  //METHOD TO CREATE NEW ACCOUNT
  Future<void> createNewUser({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
    File? userImage,
  }) async {
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
          UserModel user = UserModel(
            id: value.user!.uid,
            name: name,
            email: email,
            imageUrl: url,
            bio: 'Hey want to chat? ping me',
          );
          await addUserDetailsHive(user: user);
          //ROUTING USER TO HOMEPAGE
          navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
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
        UserModel user = UserModel(
          id: value.user!.uid,
          name: name,
          email: email,
          imageUrl: '',
          bio: 'Hey want to chat? ping me',
        );
        await addUserDetailsHive(user: user);
        // //ROUTING USER TO HOMEPAGE
        navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
      }
    });
  }

//USER LOGIN METHOD
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
          .then((value) async {
        UserModel user = UserModel(
          id: id,
          name: name,
          email: email,
          imageUrl: imageUrl,
          bio: bio,
        );
        await addUserDetailsHive(user: user);
        //ROUTING USER TO HOMEPAGE
        navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
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

//SNACKBAR
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

  //METHOD TO GET USER DETAILS IN LOGIN PAGE
  Future<Map<String, String>> getLoginUserDetails(
      {required String email}) async {
    final id = await getUseridFromEmail(email: email);
    Map<String, String> data = await getUserDetails(userId: id);
    return data;
  }

//RETRIEVING USER ID FROM USER EMAIL
  Future<String> getUseridFromEmail({required String email}) async {
    String id = '';
    await database.get().then((snapshot) {
      final result =
          snapshot.docs.firstWhere((element) => element.get('email') == email);
      id = result.id.toString().trim();
    });
    return id;
  }

  //GETTING SINGLE USER DETAILS
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

//DELETING USER IMAGE
  Future<void> deleteImage(
      {required String id, required BuildContext context}) async {
    // final navigator = Navigator.of(context);
    final storageRef = FirebaseStorage.instance.ref().child("Profile Images");
    await storageRef.child('$id.jpg').delete();
    await database.doc(id).set({'imageUrl': ''}, SetOptions(merge: true));
    await deleteImageHive();
  }

  //UPDATING USER IMAGE
  Future<void> updateImage({
    required File image,
    required String id,
  }) async {
    log('Started uploading ${DateTime.now()}');
    // final navigator = Navigator.of(context);
    final storageRef = FirebaseStorage.instance.ref().child("Profile Images");
    // await storageRef.child('$id.jpg').delete();
    await storageRef.child('$id.jpg').putFile(image).whenComplete(() async {
      final url = await storageRef.child('$id.jpg').getDownloadURL();
      await database.doc(id).set({'imageUrl': url}, SetOptions(merge: true));
      await updateImageHive(url: url);
      log('finished uploading ${DateTime.now()}');
    });
  }

  //UPDATING USER NAME
  Future<void> updateName({
    required String name,
    required String id,
  }) async {
    await database
        .doc(id)
        .set({'name': name}, SetOptions(merge: true)).then((value) {
      updateNameHive(name: name);
    });
  }

  //UPDATING USER BIO
  Future<void> updateBio({
    required String bio,
    required String id,
  }) async {
    await database
        .doc(id)
        .set({'bio': bio}, SetOptions(merge: true)).then((value) {
      updateBioHive(bio: bio);
    });
  }

  //DELETING USER
  Future deleteAccount({
    required String email,
    required String password,
    required BuildContext context,
    required String id,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      final navigator = Navigator.of(context);
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);

      await user!.reauthenticateWithCredential(credentials).then((value) async {
        log('success');
        showAlertDialogDeleting(context);
        await database.doc(id).delete(); // called from database class
        await value.user!.delete();
        await deleteAccountHive();
        navigator.pushNamedAndRemoveUntil('/welcome', (route) => false);
      });

      // return true;
    } catch (e) {
      print(e.toString());

      if (e.toString().contains('password is invalid ')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar(message: 'Invalid password. Try again'));
      } else if (e.toString().contains('no user')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar(message: 'No user found. Try again'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            snackBar(message: 'Something went wrong. Try again later'));
      }

      return 'error';
    }
  }

  void showAlertDialogDeleting(BuildContext context) {
    showCupertinoModalPopup<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => const CupertinoAlertDialog(
        title: Text('Deleting Account'),
        content: CupertinoActivityIndicator(
          radius: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}
