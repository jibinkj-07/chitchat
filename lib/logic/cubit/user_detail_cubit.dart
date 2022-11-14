import 'dart:convert';
import 'dart:developer';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'user_detail_state.dart';

class UserDetailCubit extends Cubit<UserDetailState> with HydratedMixin {
  UserDetailCubit() : super(const UserDetailInitial());
  //user authentication method
  void userAuthenticated({required String userName, required String imageUrl}) {
    log('user authentication cubit');
    emit(UserDetailState(
        userName: userName, profilePicUrl: imageUrl, isAuthenticated: true));
  }

  //user sign out method
  void userSignOut() {
    emit(const UserDetailState(
        userName: '', profilePicUrl: '', isAuthenticated: false));
  }

  @override
  UserDetailState? fromJson(Map<String, dynamic> json) {
    return UserDetailState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(UserDetailState state) {
    return state.toMap();
  }
}
