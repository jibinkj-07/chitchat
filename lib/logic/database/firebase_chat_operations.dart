import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseChatOperations {
  final database = FirebaseFirestore.instance.collection('Users');
  //-----------------CHAT OPERATIONS-----------------------

  void incrementChatCount(
      {required String targetId, required String senderId}) {
    final targetFolder =
        database.doc(targetId).collection("messages").doc(senderId);
    database.doc(targetId).get().then((value) {
      targetFolder.get().then((data) {
        log('called increment function ${data.get('unread_count')}');
        if (data.get('isNew') && data.get('unread_count') == 1) {
          database.doc(targetId).set(
            {
              'chat_count': value.get('chat_count') + 1,
            },
            SetOptions(merge: true),
          );
        }
      });
    });
  }

  void decrementChatCount({required String currentId}) {
    //changing chat_count for target user
    database.doc(currentId).get().then((value) {
      if (value.get('chat_count') > 0) {
        database.doc(currentId).set(
          {
            'chat_count': value.get('chat_count') - 1,
          },
          SetOptions(merge: true),
        );
      } else {
        database.doc(currentId).set(
          {
            'chat_count': 0,
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  void clearChatCount({required String targetId, required String senderId}) {
    final targetFolder =
        database.doc(targetId).collection("messages").doc(senderId);
    database.doc(targetId).get().then((value) {
      targetFolder.get().then((data) {
        log('called clear chatcount function ${data.get('unread_count')}');
        if (data.get('isNew') && data.get('unread_count') > 0) {
          if (value.get('chat_count') > 0) {
            database.doc(targetId).set(
              {
                'chat_count': value.get('chat_count') - 1,
              },
              SetOptions(merge: true),
            );
          } else {
            database.doc(targetId).set(
              {
                'chat_count': 0,
              },
              SetOptions(merge: true),
            );
          }
        }
      });
    });
  }

  void editMessage(
      {required String senderid,
      required String targetid,
      required String messageId,
      required String message}) {
    final target = database
        .doc(targetid)
        .collection('messages')
        .doc(senderid)
        .collection('chats')
        .doc(messageId);

    final sender = database
        .doc(senderid)
        .collection('messages')
        .doc(targetid)
        .collection('chats')
        .doc(messageId);

    sender.set(
      {'body': message},
      SetOptions(merge: true),
    );
    target.set(
      {'body': message},
      SetOptions(merge: true),
    );
  }

  void sendMessage({
    required String senderId,
    required String targetId,
    required String targetName,
    required String senderName,
    required String body,
    required String type,
    required bool isReplyingMessage,
    required String replyingParentMessage,
    required String replyingParentMessageType,
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
      'replyingParentMessageType': replyingParentMessageType,
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
        'replyingParentMessageType': replyingParentMessageType,
        'time': time,
      });

      senderFolder.set(
        {
          'last_message': body,
          'time': time,
          'isNew': false,
          'id': value.id,
          'senderName': senderName,
          'targetName': targetName,
          'isNotified': true,
          'unread_count': 0,
          'isReported': false,
          'isReportedByMe': false,
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
          'isNotified': false,
          'id': value.id,
          'senderName': senderName,
          'targetName': targetName,
          'unread_count': unreadCount + 1,
          'isReported': false,
          'isReportedByMe': false,
        },
        SetOptions(merge: true),
      ).then((_) {
        incrementChatCount(targetId: targetId, senderId: senderId);
      });
    });
  }

  void viewedChat({required String senderId, required String targetId}) {
    final ref = database.doc(senderId).collection('messages').doc(targetId);
    ref.get().then((value) {
      if (value.exists) {
        ref.set(
          {
            'isNew': false,
            'unread_count': 0,
          },
          SetOptions(merge: true),
        );
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
  Future<void> deleteMessageForMe({
    required String messageId,
    required String senderId,
    required String targetId,
    required String type,
    required String message,
    required bool deleteForAll,
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
      if (type == 'image' && deleteForAll) {
        log('deleting image');
        await deleteImageMessage(
          messageId: messageId,
          senderId: senderId,
          targetId: targetId,
        );
      }

      if (type == 'voice' && deleteForAll) {
        log('deleting voice');
        await deleteVoiceMessage(
          messageId: messageId,
          senderId: senderId,
          targetId: targetId,
        );
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
    required String targetId,
  }) async {
    final filePath = '$senderId$targetId';
    final storageRef =
        FirebaseStorage.instance.ref().child("Chat Images").child(filePath);
    await storageRef.child('$messageId.jpg').delete();
  }

  Future<void> deleteVoiceMessage({
    required String messageId,
    required String senderId,
    required String targetId,
  }) async {
    final filePath = '$senderId$targetId';
    final storageRef =
        FirebaseStorage.instance.ref().child("Chat Voices").child(filePath);
    await storageRef.child('$messageId.aac').delete();
  }

  //deleting message for all
  Future<void> deleteMessageForAll(
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
        deleteForAll: true,
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
            'isNew': true,
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
        'unread_count': 0,
      },
      SetOptions(merge: true),
    );
  }

  //clear chat for all
  Future<void> clearChatForAll(
      {required String senderId,
      required String targetId,
      required String message}) async {
    final filePathSender = '$senderId$targetId';
    final filePathTarget = '$targetId$senderId';

    try {
      final senderImageList = await FirebaseStorage.instance
          .ref()
          .child("Chat Images")
          .child(filePathSender)
          .listAll();

      for (var item in senderImageList.items) {
        item.delete();
      }
    } catch (e) {
      log('error in deleting sender storage bucket ${e.toString()}');
    }

    try {
      final senderVoiceList = await FirebaseStorage.instance
          .ref()
          .child("Chat Voices")
          .child(filePathSender)
          .listAll();
      for (var item in senderVoiceList.items) {
        item.delete();
      }
    } catch (e) {
      log('error in deleting sender storage bucket voice ${e.toString()}');
    }

    try {
      final targetImageList = await FirebaseStorage.instance
          .ref()
          .child("Chat Images")
          .child(filePathTarget)
          .listAll();
      for (var item in targetImageList.items) {
        item.delete();
      }
    } catch (e) {
      log('error in deleting target storage bucket ${e.toString()}');
    }

    try {
      final targetVoiceList = await FirebaseStorage.instance
          .ref()
          .child("Chat Voices")
          .child(filePathTarget)
          .listAll();
      for (var item in targetVoiceList.items) {
        item.delete();
      }
    } catch (e) {
      log('error in deleting target storage bucket voices${e.toString()}');
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
        'unread_count': 0,
      },
      SetOptions(merge: true),
    );

    clearChatCount(targetId: targetId, senderId: senderId);
  }

  Future<void> sendImage(
      {required String senderId,
      required String targetId,
      required bool isReplying,
      required bool isRepliedToMe,
      required String parentMessage,
      required String targetName,
      required String senderName,
      required String replyingParentMessageType,
      required String caption,
      required File image}) async {
    final time = DateTime.now();
    String id = '';
    final filePath = '$senderId$targetId';
    final storageRef =
        FirebaseStorage.instance.ref().child("Chat Images").child(filePath);
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
      'caption': caption,
      'isReplyingMessage': isReplying,
      'repliedTo': parentMessage,
      'repliedToMe': isRepliedToMe,
      'replyingParentMessageType': replyingParentMessageType,
      'time': time,
    }).then((value) async {
      id = value.id;
      senderEnd.set({
        'id': id,
        'isNew': false,
        'isNotified': true,
        'last_message': 'sending photo',
        'time': time,
        'unread_count': 0,
        'senderName': senderName,
        'targetName': targetName,
        'isReported': false,
        'isReportedByMe': false,
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
            'caption': caption,
            'isReplyingMessage': isReplying,
            'repliedTo': parentMessage,
            'replyingParentMessageType': replyingParentMessageType,
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

          //changing chat_count for target user
          database.doc(targetId).get().then((value) {
            targetEnd.get().then((data) {
              if (data.get('unread_count') == 0) {
                database.doc(targetId).set(
                  {
                    'chat_count': value.get('chat_count') + 1,
                  },
                  SetOptions(merge: true),
                );
              }
            });
          });

          targetEnd.set({
            'id': id,
            'isNew': true,
            'isNotified': false,
            'last_message': '🖼️ Photo',
            'time': uploadedTime,
            'unread_count': unreadCount + 1,
            'isReported': false,
            'senderName': senderName,
            'targetName': targetName,
            'isReportedByMe': false,
          }, SetOptions(merge: true)).then((_) {
            incrementChatCount(targetId: targetId, senderId: senderId);
          });
        });
      } catch (e) {
        log('error on uploading image ${e.toString()}');
        senderEnd.collection('chats').doc(id).delete();
        senderEnd.set({
          'last_message': 'Failed to send photo',
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> sendVoice(
      {required String senderId,
      required String targetId,
      required bool isReplying,
      required String targetName,
      required String senderName,
      required bool isRepliedToMe,
      required String parentMessage,
      required String replyingParentMessageType,
      required File voiceMessage}) async {
    final time = DateTime.now();
    String id = '';
    final filePath = '$senderId$targetId';
    final storageRef =
        FirebaseStorage.instance.ref().child("Chat Voices").child(filePath);
    final senderEnd =
        database.doc(senderId).collection('messages').doc(targetId);

    final targetEnd =
        database.doc(targetId).collection('messages').doc(senderId);
    //setting sending message in sender user end

    senderEnd.collection('chats').add({
      'body': '',
      'type': 'voice',
      'read': false,
      'readTime': null,
      'sentByMe': true,
      'isReplyingMessage': isReplying,
      'repliedTo': parentMessage,
      'replyingParentMessageType': replyingParentMessageType,
      'repliedToMe': isRepliedToMe,
      'time': time,
    }).then((value) async {
      id = value.id;
      senderEnd.set({
        'id': id,
        'isNew': false,
        'isNotified': true,
        'last_message': 'sending voice',
        'time': time,
        'unread_count': 0,
        'isReported': false,
        'senderName': senderName,
        'targetName': targetName,
        'isReportedByMe': false,
      }, SetOptions(merge: true));

      //uploading voice
      try {
        await storageRef
            .child('$id.aac')
            .putFile(voiceMessage)
            .whenComplete(() async {
          final url = await storageRef.child('$id.aac').getDownloadURL();
          final uploadedTime = DateTime.now();

          //setting message
          senderEnd.collection('chats').doc(id).set({
            'body': url,
            'time': uploadedTime,
          }, SetOptions(merge: true));

          senderEnd.set({
            'last_message': '🎙️Voice sent',
            'time': uploadedTime,
          }, SetOptions(merge: true));

          targetEnd.collection('chats').doc(id).set({
            'body': url,
            'type': 'voice',
            'read': false,
            'readTime': null,
            'sentByMe': false,
            'isReplyingMessage': isReplying,
            'repliedTo': parentMessage,
            'replyingParentMessageType': replyingParentMessageType,
            'repliedToMe': isRepliedToMe,
            'time': uploadedTime,
          });
          int unreadCount = 0;
          try {
            unreadCount = await targetEnd
                .get()
                .then((value) => value.get('unread_count'));
          } on Exception catch (e) {
            log('error in sending voice ${e.toString()}');
          }

          targetEnd.set({
            'id': id,
            'isNew': true,
            'isNotified': false,
            'last_message': '🎙️Voice',
            'time': uploadedTime,
            'unread_count': unreadCount + 1,
            'isReported': false,
            'isReportedByMe': false,
            'senderName': senderName,
            'targetName': targetName,
          }, SetOptions(merge: true)).then((_) {
            incrementChatCount(targetId: targetId, senderId: senderId);
          });
        });
      } catch (e) {
        log('error on uploading voice on target end ${e.toString()}');
        senderEnd.collection('chats').doc(id).delete();
        senderEnd.set({
          'last_message': 'Failed to send voice',
        }, SetOptions(merge: true));
      }
    });
  }
}
