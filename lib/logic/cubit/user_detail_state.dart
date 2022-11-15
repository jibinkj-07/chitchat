part of 'user_detail_cubit.dart';

@immutable
class UserDetailState extends Equatable {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String profilePicUrl;
  final bool isAuthenticated;
  const UserDetailState(
      {required this.name,
      required this.id,
      required this.email,
      required this.bio,
      required this.profilePicUrl,
      required this.isAuthenticated});

  @override
  List<Object> get props => [];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
      'isAuthenticated': isAuthenticated,
    };
  }

  factory UserDetailState.fromMap(Map<String, dynamic> map) {
    return UserDetailState(
      bio: map['bio'] as String,
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
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
      : super(
            name: '',
            isAuthenticated: false,
            profilePicUrl: '',
            email: '',
            id: '',
            bio: '');
}
