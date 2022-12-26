import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/database/user_profile.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/single_chat_screen.dart';
import 'package:chitchat/widgets/general/user_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../logic/database/firebase_operations.dart';

class AllChatSearch extends StatefulWidget {
  final String currentUserid;
  const AllChatSearch({
    super.key,
    required this.currentUserid,
  });

  @override
  State<AllChatSearch> createState() => _AllChatSearchState();
}

class _AllChatSearchState extends State<AllChatSearch> {
  FirebaseOperations firebaseOperations = FirebaseOperations();
  List<Map<String, dynamic>> allUsersFromDB = [];
  List<Map<String, dynamic>> allUsers = [];
  String query = '';
  late TextEditingController searchTextController;
  FocusNode focusNode = FocusNode();

  //METHOD TO READ ALL CHAT USERS FROM DB
  Future<void> getAllUsers() async {
    List<Map<String, dynamic>> data = [];
    final users = await firebaseOperations.getChatUsers(
        currentUserid: widget.currentUserid);

    for (int i = 0; i < users.length; i++) {
      final details = await firebaseOperations.getUserDetails(
          userId: users[i]['targetUserid']);
      data.add(details);
    }

    if (!mounted) return;
    setState(() {
      allUsersFromDB = data;
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
    //search method
    void searchUser(String query) {
      final users = allUsersFromDB.where((user) {
        final nameLower = user['name'].toString().toLowerCase();
        final usernameLower = user['username'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return nameLower.contains(searchQuery) ||
            usernameLower.contains(searchQuery);
        // emailLower.contains(searchQuery);
      }).toList();
      setState(() {
        this.query = query;
        allUsers = users;
      });
    }

    // log('all friends are ${allUsers.toString()}');
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
                      placeholder: 'Search Friends',
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
              child: Expanded(
                child: query == ''
                    ? const SizedBox()
                    : allUsers.isNotEmpty
                        ? ListView.builder(
                            itemBuilder: (context, index) {
                              // return ChatFriendsDetails(
                              //     targetid: allUsers[index]['targetUserid']);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SingleChatScreen(
                                          targetUserid: allUsers[index]['id'],
                                          currentUserid: widget.currentUserid,
                                        ),
                                      ),
                                    );
                                  },
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
                                                color:
                                                    Colors.grey.withOpacity(.5),
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
                                                imageUrl: allUsers[index]
                                                    ['imageUrl'],
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            color: AppColors()
                                                                .primaryColor,
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  color: AppColors().redColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  title: Row(
                                    children: [
                                      allUsers[index]['name']
                                                  .toString()
                                                  .length >
                                              30
                                          ? Text(
                                              '${allUsers[index]['name'].toString().substring(0, 28)}..',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : Text(
                                              allUsers[index]['name'],
                                              style: const TextStyle(
                                                fontSize: 14,
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
                                ),
                              );
                            },
                            itemCount: allUsers.length)
                        : query.trim() == ''
                            ? const SizedBox()
                            : Text(
                                "No friends found with '$query'",
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

class ChatFriendsDetails extends StatelessWidget {
  final String targetid;
  const ChatFriendsDetails({
    super.key,
    required this.targetid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(targetid)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final name = snapshot.data!.get('name');
            return ListTile(
              title: Text(name),
            );
          }
          return const SizedBox();
        });
  }
}
