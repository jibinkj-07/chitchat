import 'dart:developer';
import 'package:chitchat/logic/database/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

ValueNotifier<List<UserModel>> userDetailNotifier = ValueNotifier([]);

Future<void> addUserDetailsHive({required UserModel user}) async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  log('added user ${user.toString()}');
  await userDB.add(user);

  userDetailNotifier.value.add(user);
  userDetailNotifier.notifyListeners();
}

Future<void> getUserDetailHive() async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  userDetailNotifier.value.clear();

  userDetailNotifier.value.addAll(userDB.values);
  userDetailNotifier.notifyListeners();
}

Future<void> updateImageHive({required String url}) async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  int lastIndex = userDB.length - 1;
  if (lastIndex < 0) return;

  UserModel userModel = userDB.values.toList()[lastIndex];
  userModel.imageUrl = url;
  await userDB.putAt(lastIndex, userModel);
  getUserDetailHive();
}

Future<void> deleteImageHive() async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  int lastIndex = userDB.length - 1;
  if (lastIndex < 0) return;

  UserModel userModel = userDB.values.toList()[lastIndex];
  userModel.imageUrl = '';
  await userDB.putAt(lastIndex, userModel);
  getUserDetailHive();
}

Future<void> updateNameHive({required String name}) async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  int lastIndex = userDB.length - 1;
  if (lastIndex < 0) return;

  UserModel userModel = userDB.values.toList()[lastIndex];
  userModel.name = name;
  await userDB.putAt(lastIndex, userModel);
  getUserDetailHive();
}

Future<void> updateBioHive({required String bio}) async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  int lastIndex = userDB.length - 1;
  if (lastIndex < 0) return;

  UserModel userModel = userDB.values.toList()[lastIndex];
  userModel.bio = bio;
  await userDB.putAt(lastIndex, userModel);
  getUserDetailHive();
}

Future<void> deleteAccountHive() async {
  final userDB = await Hive.openBox<UserModel>('user_db');
  userDB.deleteFromDisk();
  userDetailNotifier.value.clear();
  userDetailNotifier.notifyListeners();
}
