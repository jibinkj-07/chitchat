import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/widgets/chat/single_chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../logic/database/firebase_operations.dart';
import '../utils/app_colors.dart';

class AddChatScreen extends StatefulWidget {
  final String currentUserid;
  const AddChatScreen({
    super.key,
    required this.currentUserid,
  });

  @override
  State<AddChatScreen> createState() => _AddChatScreenState();
}

class _AddChatScreenState extends State<AddChatScreen> {
  FirebaseOperations firebaseOperations = FirebaseOperations();
  List<Map<String, dynamic>> allUsersFromDB = [];
  List<Map<String, dynamic>> allUsers = [];
  String query = '';
  bool isSearching = false;

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
    getAllUsers();
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            topBar(context: context),
            const Divider(height: 0),
            Expanded(
              child: listOfFriends(),
            ),
          ],
        ),
      ),
    );
  }

  Widget topBar({required BuildContext context}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (isSearching) {
                setState(() {
                  isSearching = false;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black,
            splashRadius: 20.0,
            iconSize: 20.0,
          ),
          if (isSearching)
            Expanded(
              child: CupertinoSearchTextField(
                autofocus: true,
                placeholder: 'Search people',
                onChanged: (value) {
                  searchUser(value.toString());
                },
              ),
            ),
          if (!isSearching)
            const Text(
              'Select Friends',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
              icon: const Icon(
                CupertinoIcons.search,
              ),
              color: Colors.black,
              splashRadius: 20.0,
              iconSize: 20.0,
            ),
        ],
      ),
    );
  }

  Widget listOfFriends() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: allUsers.isNotEmpty
          ? ListView.builder(
              itemBuilder: (c, index) {
                final bio = allUsers[index]['bio'].toString().length > 40
                    ? '${allUsers[index]['bio'].toString().substring(0, 37)}....'
                    : allUsers[index]['bio'];

                final name = allUsers[index]['name'].toString().length > 30
                    ? '${allUsers[index]['name'].toString().substring(0, 27)}...'
                    : allUsers[index]['name'];
                return ListTile(
                  onTap: () => widget.currentUserid == allUsers[index]['id']
                      ? null
                      : Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SingleChatScreen(
                              targetUserid: allUsers[index]['id'],
                              currentUserid: widget.currentUserid,
                            ),
                          ),
                        ),
                  leading: allUsers[index]['imageUrl'] == ''
                      ? Hero(
                          tag: allUsers[index]['id'],
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: .5,
                                color: Colors.grey.withOpacity(.5),
                              ),
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
                          tag: allUsers[index]['id'],
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
                                imageUrl: allUsers[index]['imageUrl'],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            color: AppColors().primaryColor,
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: AppColors().redColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                  title: Row(
                    children: [
                      widget.currentUserid == allUsers[index]['id']
                          ? const Text(
                              'You',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      if (allUsers[index]['verified'])
                        Icon(
                          Iconsax.verify5,
                          color: AppColors().primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                  subtitle: Text(
                    bio,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: widget.currentUserid == allUsers[index]['id']
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              itemCount: allUsers.length,
            )
          : query.trim() == ''
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    "No friends found with '$query'",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors().textColorBlack.withOpacity(.5),
                    ),
                  ),
                ),
    );
  }
}
