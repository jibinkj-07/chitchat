import 'dart:developer';
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
              width: 60, height: 60, shape: BoxShape.circle),
          titleStyle: SkeletonLineStyle(
              height: 16,
              minLength: 200,
              randomLength: true,
              borderRadius: BorderRadius.circular(12)),
          subtitleStyle: SkeletonLineStyle(
              height: 12,
              maxLength: 200,
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
          // const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: CupertinoSearchTextField(
              onChanged: (String value) {
                log('The text has changed to: $value');
              },
              onSubmitted: (String value) {
                log('Submitted text: $value');
              },
            ),
          ),
          const SizedBox(height: 10),
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
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.withOpacity(.6),
                              backgroundImage: const AssetImage(
                                'assets/images/profile_dark.png',
                              ),
                            ),
                          )
                        : Hero(
                            tag: id,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.withOpacity(.6),
                              backgroundImage: NetworkImage(
                                usersFromDb[index]['imageUrl'],
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
                              'Connect',
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
