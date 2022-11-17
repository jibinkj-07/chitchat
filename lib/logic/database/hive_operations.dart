import 'dart:developer';
import 'package:flutter/material.dart';

ValueNotifier<Map<String, String>> userDetailsNotifier = ValueNotifier({});

void addUserDetails(
    {required String id,
    required String name,
    required String email,
    required String url,
    required String bio}) {
  userDetailsNotifier.value.addAll({
    'id': id,
    'name': name,
    'email': email,
    'url': url,
    'bio': bio,
  });
  log('User detail added and values are ${userDetailsNotifier.value.toString()}');
  userDetailsNotifier.notifyListeners();
}
