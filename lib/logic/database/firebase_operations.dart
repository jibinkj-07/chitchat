import 'dart:developer';
import 'dart:io';
import 'package:chitchat/logic/database/hive_operations.dart';
import 'package:chitchat/logic/database/user_model.dart';
import 'package:chitchat/logic/database/user_profile.dart';
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
              'username': data.get('username'),
              'imageUrl': data.get('imageUrl'),
              'bio': data.get('bio'),
              'status': data.get('status'),
              'verified': data.get('verified'),
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

  //CHECK FOR USERNAME
  Future<bool> checkForUsername({required String username}) async {
    QuerySnapshot querySnapshot = await database.get();
    try {
      querySnapshot.docs.firstWhere((element) {
        log('names are ${element.get('name')}');
        return element.get('username') == username;
      });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  //METHOD TO CREATE NEW ACCOUNT
  Future<bool> createNewUser({
    required String email,
    required String password,
    required String name,
    required String username,
    required BuildContext context,
    File? userImage,
  }) async {
    final storageRef = FirebaseStorage.instance.ref().child("Profile Images");
    final navigator = Navigator.of(context);

    try {
      final createdTime = DateTime.now();
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
            final url = await storageRef
                .child('${value.user!.uid}.jpg')
                .getDownloadURL();
            database.doc(value.user!.uid).set(
              {
                'name': name,
                'email': email,
                'username': username,
                'imageUrl': url,
                'bio': 'Hey want to chat? ping me',
                'verified': false,
                'status': 'online',
                'created': createdTime,
              },
              SetOptions(merge: true),
            );
            UserModel user = UserModel(
              id: value.user!.uid,
              name: name,
              username: username,
              email: email,
              imageUrl: url,
              bio: 'Hey want to chat? ping me',
              joined: createdTime,
            );
            await addUserDetailsHive(user: user);
            // //ROUTING USER TO HOMEPAGE
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
              'username': username,
              'verified': false,
              'bio': 'Hey want to chat? ping me',
              'status': 'online',
              'created': createdTime,
            },
            SetOptions(merge: true),
          );
          UserModel user = UserModel(
            id: value.user!.uid,
            name: name,
            email: email,
            username: username,
            imageUrl: '',
            bio: 'Hey want to chat? ping me',
            joined: createdTime,
          );
          await addUserDetailsHive(user: user);
          // //ROUTING USER TO HOMEPAGE
          navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
        }
      });
    } catch (e) {
      log(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(message: 'Something went wrong. Try again later'),
      );
      return false;
    }
    return true;
  }

//USER LOGIN METHOD
  Future<bool> loginUser({
    required String email,
    required String password,
    required String name,
    required String id,
    required String bio,
    required String username,
    required String imageUrl,
    required bool verified,
    required DateTime joined,
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
          username: username,
          imageUrl: imageUrl,
          bio: bio,
          joined: joined,
        );
        await addUserDetailsHive(user: user);
        // //ROUTING USER TO HOMEPAGE
        navigator.pushNamedAndRemoveUntil('/homeScreen', (route) => false);
      });
    } catch (e) {
      log(e.toString());
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
      return false;
    }
    return true;
  }

//SNACKBAR
  SnackBar snackBar({required String message}) {
    return SnackBar(
      backgroundColor: AppColors().redColor,
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
  Future<Map<String, dynamic>> getLoginUserDetails(
      {required String email}) async {
    final id = await getUseridFromEmail(email: email);
    Map<String, dynamic> data = await getUserDetails(userId: id);
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
  Future<Map<String, dynamic>> getUserDetails({required String userId}) async {
    Map<String, dynamic> details = {};
    await database.doc(userId).get().then((snapshot) {
      details = {
        'id': snapshot.id,
        'name': snapshot.get('name'),
        'username': snapshot.get('username'),
        'email': snapshot.get('email'),
        'imageUrl': snapshot.get('imageUrl'),
        'verified': snapshot.get('verified'),
        'status': snapshot.get('status'),
        'bio': snapshot.get('bio'),
        'joined': snapshot.get('created').toDate(),
      };
    });
    return details;
  }

//DELETING USER IMAGE
  Future<void> deleteImage({required String id}) async {
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
  Future<bool> updateName({
    required String name,
    required String id,
  }) async {
    try {
      await database
          .doc(id)
          .set({'name': name}, SetOptions(merge: true)).then((value) async {
        await updateNameHive(name: name);
      });
    } catch (e) {
      log('error in update bio ${e.toString()}');
      return false;
    }
    return true;
  }

  //UPDATING USER BIO
  Future<bool> updateBio({
    required String bio,
    required String id,
  }) async {
    try {
      await database
          .doc(id)
          .set({'bio': bio}, SetOptions(merge: true)).then((value) {
        updateBioHive(bio: bio);
      });
    } catch (e) {
      log('error in update bio ${e.toString()}');
      return false;
    }
    return true;
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

  //RESET PASSWORD
  Future<String> resetPassword({required String email}) async {
    String status = 'success';
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_) {
      log('auth helper pw reset done ');
    }).catchError((e) {
      log('error in pw reset ${e.toString()}');
      status = e.toString();
    });
    return status;
  }

  //adding status of users
  void changeStatus({required String userId, required String status}) {
    database.doc(userId).set(
      {'status': status},
      SetOptions(merge: true),
    );
  }

  //getting user status
  Future<String> getUserStatus({required String userId}) async {
    String status =
        await database.doc(userId).get().then((value) => value.get('status'));
    return status;
  }

  //-----------------CHAT OPERATIONS-----------------------

  void sendMessage(
      {required String senderId,
      required String targetId,
      required String body}) {
    final time = DateTime.now();
    final senderFolder =
        database.doc(senderId).collection("messages").doc(targetId);
    final targetFolder =
        database.doc(targetId).collection("messages").doc(senderId);

    //creating copy in sender folder
    senderFolder.collection('chats').add({
      'body': body.trim(),
      'type': 'text',
      'read': false,
      'readTime': null,
      'sentByMe': true,
      'time': time,
    }).then((value) {
      //creating copy in tager folder
      targetFolder.collection('chats').doc(value.id).set({
        'body': body.trim(),
        'type': 'text',
        'read': false,
        'readTime': null,
        'sentByMe': false,
        'time': time,
      });

      senderFolder.set(
        {
          'last_message': body,
          'time': time,
          'isNew': false,
          'id': value.id,
        },
        SetOptions(merge: true),
      );

      targetFolder.set(
        {
          'last_message': body,
          'time': time,
          'isNew': true,
          'id': value.id,
        },
        SetOptions(merge: true),
      );
    });
  }

  void changeNewMessageStatus(
      {required String senderId, required String targetId}) {
    database.doc(senderId).collection('messages').doc(targetId).set(
      {'isNew': false},
      SetOptions(merge: true),
    );
  }

  void changeReadMessageStatus({
    required String senderId,
    required String targetId,
    required String messageId,
  }) {
    final ref = database
        .doc(targetId)
        .collection('messages')
        .doc(senderId)
        .collection('chats')
        .doc(messageId);

    ref.get().then((value) {
      if (!value.get('read')) {
        ref.set({
          'read': true,
          'readTime': DateTime.now(),
        }, SetOptions(merge: true));
      }
    });
  }

//deleting message of self
  void deleteMessageForMe(
      {required String messageId,
      required String senderId,
      required String targetId}) async {
    String id = '';
    final deleteMsg = database
        .doc(senderId)
        .collection('messages')
        .doc(targetId)
        .collection('chats')
        .doc(messageId);

    //getting last message id
    await database
        .doc(senderId)
        .collection('messages')
        .doc(targetId)
        .get()
        .then((value) {
      id = value.get('id');
    });
    if (id == messageId) {
      deleteMsg.delete();
      database.doc(senderId).collection('messages').doc(targetId).set(
        {
          'last_message': 'Deleted for you',
          'time': DateTime.now(),
          'isNew': false,
          'id': '',
        },
        SetOptions(merge: true),
      );
    } else {
      deleteMsg.delete();
    }
  }

  //deleting message for all
  void deleteMessageForAll(
      {required String messageId,
      required String senderId,
      required String targetId}) async {
    String targetMsgId = '', senderMsgId = '';
    final deleteMsgSender = database
        .doc(senderId)
        .collection('messages')
        .doc(targetId)
        .collection('chats')
        .doc(messageId);
    final deleteMsgTarget = database
        .doc(targetId)
        .collection('messages')
        .doc(senderId)
        .collection('chats')
        .doc(messageId);

    //getting last message id for sender
    await database
        .doc(senderId)
        .collection('messages')
        .doc(targetId)
        .get()
        .then((value) {
      senderMsgId = value.get('id');
    });
    if (senderMsgId == messageId) {
      deleteMsgSender.delete();
      database.doc(senderId).collection('messages').doc(targetId).set(
        {
          'last_message': 'Deleted for all',
          'time': DateTime.now(),
          'isNew': false,
          'id': '',
        },
        SetOptions(merge: true),
      );
    } else {
      deleteMsgSender.delete();
    }

    //getting last message id for target
    await database
        .doc(targetId)
        .collection('messages')
        .doc(senderId)
        .get()
        .then((value) {
      targetMsgId = value.get('id');
    });
    if (targetMsgId == messageId) {
      deleteMsgTarget.delete();
      database.doc(targetId).collection('messages').doc(senderId).set(
        {
          'last_message': 'Deleted for all',
          'time': DateTime.now(),
          'isNew': false,
          'id': '',
        },
        SetOptions(merge: true),
      );
    } else {
      deleteMsgTarget.delete();
    }
  }
}
