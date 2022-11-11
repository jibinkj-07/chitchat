import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'user_detail_state.dart';

class UserDetailCubit extends Cubit<UserDetailState> {
  UserDetailCubit() : super(const UserDetailInitial());
  //user authentication method
  void userAuthenticated({required String userName, required String imageUrl}) {
    emit(UserDetailState(
        userName: userName, profilePicUrl: imageUrl, isAuthenticated: true));
  }

  //user sign out method
  void userSignOut() {
    emit(const UserDetailState(
        userName: '', profilePicUrl: '', isAuthenticated: false));
  }
}
