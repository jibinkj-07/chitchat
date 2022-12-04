import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseChatOperations {
  final database = FirebaseFirestore.instance.collection('Users');
  //-----------------CHAT OPERATIONS-----------------------

  void sendMessage({
    required String senderId,
    required String targetId,
    required String body,
    required String type,
    required bool isReplyingMessage,
    required String replyingParentMessage,
    required bool isReplyingToMyMessage,
  }) {
    final time = DateTime.now();
    final senderFolder =
        database.doc(senderId).collection("messages").doc(targetId);
    final targetFolder =
        database.doc(targetId).collection("messages").doc(senderId);

    //creating copy in sender folder
    senderFolder.collection('chats').add({
      'body': body.trim(),
      'type': type,
      'read': false,
      'readTime': null,
      'sentByMe': true,
      'isReplyingMessage': isReplyingMessage,
      'repliedTo': replyingParentMessage,
      'repliedToMe': isReplyingToMyMessage,
      'time': time,
    }).then((value) async {
      //creating copy in tager folder
      targetFolder.collection('chats').doc(value.id).set({
        'body': body.trim(),
        'type': 'text',
        'read': false,
        'readTime': null,
        'sentByMe': false,
        'isReplyingMessage': isReplyingMessage,
        'repliedTo': replyingParentMessage,
        'repliedToMe': isReplyingToMyMessage,
        'time': time,
      });

      senderFolder.set(
        {
          'last_message': body,
          'time': time,
          'isNew': false,
          'id': value.id,
          'unread_count': 0,
        },
        SetOptions(merge: true),
      );
      int unreadCount = 0;
      //getting unread message count from  target end

      unreadCount = await targetFolder.get().then((value) {
        if (value.exists) {
          return value.get('unread_count');
        } else {
          return 0;
        }
      });

      targetFolder.set(
        {
          'last_message': body,
          'time': time,
          'isNew': true,
          'id': value.id,
          'unread_count': unreadCount + 1,
        },
        SetOptions(merge: true),
      );
    });
  }

  void viewedChat({required String senderId, required String targetId}) {
    final ref = database.doc(senderId).collection('messages').doc(targetId);
    ref.get().then((value) {
      if (value.exists) {
        if (value.get('isNew')) {
          ref.set(
            {
              'isNew': false,
              'unread_count': 0,
            },
            SetOptions(merge: true),
          );
        }
      }
    });
  }

  void readMessage({
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
      try {
        if (!value.get('read')) {
          ref.set({
            'read': true,
            'readTime': DateTime.now(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        log('error from fb ${e.toString()}');
      }
    });
  }

//deleting message of self
  void deleteMessageForMe({
    required String messageId,
    required String senderId,
    required String targetId,
    required String type,
    required String message,
    required bool deleteImageForAll,
  }) async {
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
        .then((value) async {
      id = value.get('id');

      //deleting message
      if (type == 'image' && deleteImageForAll) {
        log('deleting image');
        await deleteImageMessage(messageId: messageId, senderId: senderId);
      }
      deleteMsg.delete();
      if (id == messageId) {
        database.doc(senderId).collection('messages').doc(targetId).set(
          {
            'last_message': message,
            'time': DateTime.now(),
            'isNew': false,
            'id': '',
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  Future<void> deleteImageMessage({
    required String messageId,
    required String senderId,
  }) async {
    final storageRef =
        FirebaseStorage.instance.ref().child("Chat Images").child(senderId);
    await storageRef.child('$messageId.jpg').delete();
  }

  //deleting message for all
  void deleteMessageForAll(
      {required String messageId,
      required String type,
      required String senderId,
      required String targetId}) async {
    String targetMsgId = '';

    deleteMessageForMe(
        messageId: messageId,
        senderId: senderId,
        targetId: targetId,
        type: type,
        deleteImageForAll: true,
        message: 'Message deleted for all');

    final deleteMsgTarget = database
        .doc(targetId)
        .collection('messages')
        .doc(senderId)
        .collection('chats')
        .doc(messageId);

    //getting last message id for target
    await database
        .doc(targetId)
        .collection('messages')
        .doc(senderId)
        .get()
        .then((value) {
      targetMsgId = value.get('id');
      deleteMsgTarget.delete();
      if (targetMsgId == messageId) {
        database.doc(targetId).collection('messages').doc(senderId).set(
          {
            'last_message': 'Message deleted for all',
            'time': DateTime.now(),
            'isNew': false,
            'id': '',
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  //clear chat for me
  Future<void> clearChatForMe(
      {required String senderId,
      required String targetId,
      required String message}) async {
    // database.doc(senderId).collection('messages').doc(targetId).collection('chats').

    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection = database
        .doc(senderId)
        .collection('messages')
        .doc(targetId)
        .collection('chats');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    database.doc(senderId).collection('messages').doc(targetId).set(
      {
        'last_message': message,
        'time': DateTime.now(),
        'isNew': false,
        'id': '',
      },
      SetOptions(merge: true),
    );
  }

  //clear chat for all
  Future<void> clearChatForAll(
      {required String senderId,
      required String targetId,
      required String message}) async {
    try {
      final list = await FirebaseStorage.instance
          .ref()
          .child("Chat Images")
          .child(senderId)
          .listAll();
      for (var item in list.items) {
        item.delete();
      }
    } catch (e) {
      log('error in deleting $senderId storage bucket ${e.toString()}');
    }

    clearChatForMe(senderId: senderId, targetId: targetId, message: message);
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection = database
        .doc(targetId)
        .collection('messages')
        .doc(senderId)
        .collection('chats');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    database.doc(targetId).collection('messages').doc(senderId).set(
      {
        'last_message': message,
        'time': DateTime.now(),
        'isNew': false,
        'id': '',
      },
      SetOptions(merge: true),
    );
  }

  Future<void> sendImage(
      {required String senderId,
      required String targetId,
      required bool isReplying,
      required bool isRepliedToMe,
      required String parentMessage,
      required File image}) async {
    final time = DateTime.now();
    String id = '';

    final storageRef =
        FirebaseStorage.instance.ref().child("Chat Images").child(senderId);
    // await storageRef.child('$id.jpg').delete();
    final senderEnd =
        database.doc(senderId).collection('messages').doc(targetId);

    final targetEnd =
        database.doc(targetId).collection('messages').doc(senderId);
    //setting sending message in sender user end

    senderEnd.collection('chats').add({
      'body': '',
      'type': 'image',
      'read': false,
      'readTime': null,
      'sentByMe': true,
      'isReplyingMessage': isReplying,
      'repliedTo': parentMessage,
      'repliedToMe': isRepliedToMe,
      'time': time,
    }).then((value) async {
      id = value.id;
      senderEnd.set({
        'id': id,
        'isNew': false,
        'last_message': 'sending photo',
        'time': time,
        'unread_count': 0,
      }, SetOptions(merge: true));

      //uploading image
      try {
        await storageRef.child('$id.jpg').putFile(image).whenComplete(() async {
          final url = await storageRef.child('$id.jpg').getDownloadURL();
          final uploadedTime = DateTime.now();

          //setting message
          senderEnd.collection('chats').doc(id).set({
            'body': url,
            'time': uploadedTime,
          }, SetOptions(merge: true));

          senderEnd.set({
            'last_message': '🖼️ Photo sent',
            'time': uploadedTime,
          }, SetOptions(merge: true));

          targetEnd.collection('chats').doc(id).set({
            'body': url,
            'type': 'image',
            'read': false,
            'readTime': null,
            'sentByMe': false,
            'isReplyingMessage': isReplying,
            'repliedTo': parentMessage,
            'repliedToMe': isRepliedToMe,
            'time': uploadedTime,
          });
          int unreadCount = 0;
          try {
            unreadCount = await targetEnd
                .get()
                .then((value) => value.get('unread_count'));
          } on Exception catch (e) {
            log('error in sending image ${e.toString()}');
          }
          targetEnd.set({
            'id': id,
            'isNew': true,
            'last_message': '🖼️ Photo',
            'time': uploadedTime,
            'unread_count': unreadCount + 1,
          }, SetOptions(merge: true));
        });
      } catch (e) {
        log('error on uploading image ${e.toString()}');
        senderEnd.collection('chats').doc(id).delete();
        senderEnd.set({
          'last_message': 'Failed to sent photo',
        }, SetOptions(merge: true));
      }
    });
  }
}
