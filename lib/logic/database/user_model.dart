import 'package:hive_flutter/hive_flutter.dart';
part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String name;

  @HiveField(3)
  String email;

  @HiveField(4)
  String imageUrl;

  @HiveField(5)
  String bio;

  @HiveField(6)
  DateTime joined;
  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.bio,
    required this.joined,
  });
}
