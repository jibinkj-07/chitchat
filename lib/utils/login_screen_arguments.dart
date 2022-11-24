// You can pass any object to the arguments parameter.
// In this example, create a class that contains both
// a customizable title and message.
class LoginScreenArguments {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String bio;
  final String username;
  final DateTime joined;

  LoginScreenArguments({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.imageUrl,
    required this.bio,
    required this.joined,
  });
}
