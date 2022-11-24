import 'dart:developer';

import 'package:chitchat/logic/database/user_profile.dart';
import 'package:chitchat/widgets/general/user_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../logic/database/firebase_operations.dart';

class AllFriendsSearch extends StatefulWidget {
  final String currentUserid;
  const AllFriendsSearch({
    super.key,
    required this.currentUserid,
  });

  @override
  State<AllFriendsSearch> createState() => _AllFriendsSearchState();
}

class _AllFriendsSearchState extends State<AllFriendsSearch> {
  FirebaseOperations firebaseOperations = FirebaseOperations();
  List<Map<String, dynamic>> allUsersFromDB = [];
  List<Map<String, dynamic>> allUsers = [];
  String query = '';
  late TextEditingController searchTextController;
  FocusNode focusNode = FocusNode();

  //METHOD TO READ ALL USERS FROM DB
  Future<void> getAllUsers() async {
    final users = await firebaseOperations.getUsers();
    if (!mounted) return;
    setState(() {
      allUsersFromDB = users;
      allUsers = allUsersFromDB;
    });
  }

  @override
  void initState() {
    searchTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
    getAllUsers();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  //main
  @override
  Widget build(BuildContext context) {
    //opening keyboard

    //search method
    void searchUser(String query) {
      final users = allUsersFromDB.where((user) {
        final nameLower = user['name'].toString().toLowerCase();
        // final emailLower = user['email'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return nameLower.contains(searchQuery);
        // emailLower.contains(searchQuery);
      }).toList();
      setState(() {
        this.query = query;
        allUsers = users;
      });
    }

    //main
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //search bar
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: Colors.black,
                  splashRadius: 20.0,
                  iconSize: 20.0,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoSearchTextField(
                      focusNode: focusNode,
                      controller: searchTextController,
                      placeholder: 'Search people',
                      onChanged: (value) {
                        searchUser(value.toString());
                      },
                    ),
                  ),
                ),
              ],
            ),
            //body
            // search result
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: query.trim() == ''
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Iconsax.information,
                            size: 15,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Search people with their profile name or username to discover.",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: allUsers.isNotEmpty
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    UserProfile user = UserProfile(
                                        id: allUsers[index]['id'],
                                        name: allUsers[index]['name'],
                                        username: 'username',
                                        imageUrl: allUsers[index]['imageUrl'],
                                        bio: allUsers[index]['bio']);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UserDetail(
                                          user: user,
                                          currentId: widget.currentUserid,
                                        ),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    allUsers[index]['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                              itemCount: allUsers.length)
                          : Text(
                              "No user found for '$query'",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
