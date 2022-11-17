import 'package:hive_flutter/hive_flutter.dart';
part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String imageUrl;

  @HiveField(4)
  String bio;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.bio,
  });
}
