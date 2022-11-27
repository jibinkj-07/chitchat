class UserProfile {
  final String id;
  final String name;
  final String username;
  final String imageUrl;
  final bool isVerified;
  final String status;
  final String bio;
  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.isVerified,
    required this.status,
    required this.bio,
  });
}
