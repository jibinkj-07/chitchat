import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/firebase_operations.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/general/user_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../../logic/database/user_profile.dart';

class FindFriends extends StatefulWidget {
  const FindFriends({super.key});

  @override
  State<FindFriends> createState() => _FindFriendsState();
}

class _FindFriendsState extends State<FindFriends> {
  // bool isLoading = false;
  FirebaseOperations firebaseOperations = FirebaseOperations();
  List<Map<String, dynamic>> usersFromDb = [];

  @override
  void initState() {
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
                final username = usersFromDb[index]['username'];
                final name = usersFromDb[index]['name'];
                final bio = usersFromDb[index]['bio'];
                final url = usersFromDb[index]['imageUrl'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    onTap: () {
                      UserProfile user = UserProfile(
                        id: id,
                        name: name,
                        username: username,
                        bio: bio,
                        imageUrl: url,
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
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        : Hero(
                            tag: id,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: .5,
                                  color: Colors.grey,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              color: appColors.primaryColor,
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: appColors.redColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                              'Message',
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
