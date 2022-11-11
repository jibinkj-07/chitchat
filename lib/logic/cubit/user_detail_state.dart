part of 'user_detail_cubit.dart';

@immutable
class UserDetailState extends Equatable {
  final String userName;
  final String profilePicUrl;
  final bool isAuthenticated;
  const UserDetailState(
      {required this.userName,
      required this.profilePicUrl,
      required this.isAuthenticated});

  @override
  List<Object> get props => [];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'profilePicUrl': profilePicUrl,
      'isAuthenticated': isAuthenticated,
    };
  }

  factory UserDetailState.fromMap(Map<String, dynamic> map) {
    return UserDetailState(
      userName: map['userName'] as String,
      profilePicUrl: map['profilePicUrl'] as String,
      isAuthenticated: map['isAuthenticated'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDetailState.fromJson(String source) =>
      UserDetailState.fromMap(json.decode(source) as Map<String, dynamic>);
}

class UserDetailInitial extends UserDetailState {
  const UserDetailInitial()
      : super(userName: '', isAuthenticated: false, profilePicUrl: '');
}
