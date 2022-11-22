import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/user_profile.dart';
import 'package:chitchat/widgets/general/user_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class FindFriends extends StatefulWidget {
  const FindFriends({super.key});

  @override
  State<FindFriends> createState() => _FindFriendsState();
}

class _FindFriendsState extends State<FindFriends> {
  // bool isLoading = false;
  FirebaseOperations firebaseOperations = FirebaseOperations();
  List<Map<String, dynamic>> usersFromDb = [];
  List<Map<String, dynamic>> allUsers = [];
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    getAllUsers();
    super.initState();
  }

  //METHOD TO READ ALL USERS FROM DB
  Future<void> getAllUsers() async {
    final users = await firebaseOperations.getUsers();
    if (!mounted) return;
    setState(() {
      usersFromDb = users;
    });
  }

  Widget skeletonView() => SkeletonListView(
        item: SkeletonListTile(
          verticalSpacing: 12,
          leadingStyle: const SkeletonAvatarStyle(
              width: 50, height: 50, shape: BoxShape.circle),
          titleStyle: SkeletonLineStyle(
              height: 10,
              minLength: 80,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          subtitleStyle: SkeletonLineStyle(
              height: 8,
              maxLength: 120,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          hasSubtitle: true,
        ),
      );
  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Skeleton(
      isLoading: usersFromDb.isEmpty,
      skeleton: skeletonView(),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: usersFromDb.length,
              itemBuilder: (BuildContext context, int index) {
                final currentId = FirebaseAuth.instance.currentUser!.uid;
                final id = usersFromDb[index]['id'];
                final name = usersFromDb[index]['name'];
                final email = usersFromDb[index]['email'];
                final bio = usersFromDb[index]['bio'];
                final url = usersFromDb[index]['imageUrl'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    onTap: () {
                      UserProfile user = UserProfile(
                        id: id,
                        name: name,
                        email: email,
                        bio: bio,
                        url: url,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserDetail(
                            user: user,
                            currentId: currentId,
                          ),
                        ),
                      );
                    },
                    leading: url == ''
                        ? Hero(
                            tag: id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(300),
                              child: Image.asset(
                                'assets/images/profile.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Hero(
                            tag: id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(300),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CupertinoActivityIndicator(
                                  color: appColors.primaryColor,
                                  radius: 15,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: appColors.redColor,
                                ),
                              ),
                            ),
                          ),
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: currentId == id
                        ? null
                        : ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.withOpacity(.2),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                            ),
                            child: const Text(
                              'Ping',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}