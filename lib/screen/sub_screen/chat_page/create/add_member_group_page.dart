import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/user_model.dart';

import '../../../widget/user_component/user_util/userbio_comp.dart';
import '../../../widget/user_component/user_util/username_comp.dart';
import '../../../widget/user_component/user_util/userprofile_comp.dart';

class AddGroupMember extends StatefulWidget {
  List<dynamic> membersID;
  final String groupID;
  AddGroupMember({super.key, required this.membersID, required this.groupID});

  @override
  State<AddGroupMember> createState() => _AddGroupMemberState();
}

class _AddGroupMemberState extends State<AddGroupMember> {
  final _tcsearch = TextEditingController();
  List<String> selectedID = [];
  List<String> selectedUsername = [];
  List<String> suggestedID = [];
  List<String> suggestedUsername = [];
  final user = FirebaseAuth.instance.currentUser!;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final contentstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(context, appbarstyle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(context, titlestyle),
          if (selectedUsername.isNotEmpty) listAddMember(contentstyle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Suggested',
              style: titlestyle,
            ),
          ),
          streamGenerateItem()
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.5,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios_new,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      centerTitle: true,
      title: Text(
        'Add People',
        style: appbarstyle,
      ),
      actions: [
        isLoading
            ? SpinKitFadingCircle(
                size: 30,
                color: Theme.of(context).colorScheme.secondary,
              )
            : IconButton(
                onPressed: () {
                  if (selectedID.isEmpty) {
                    SnackBarUtil.showSnackBar(
                        'Please select at least one user', Colors.red);
                  } else {
                    ChatServices.addnewMembers(widget.groupID, selectedID);
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.done,
                  color: Theme.of(context).colorScheme.tertiary,
                ))
      ],
    );
  }

  Widget buildHeader(BuildContext context, TextStyle titlestyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            'To',
            style: titlestyle,
          ),
          const SizedBox(
            height: 10,
          ),
          buildSearchField(),
        ],
      ),
    );
  }

  Widget listAddMember(TextStyle contentstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedUsername.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Theme.of(context).colorScheme.secondary),
              child: Center(
                  child: Text(
                selectedUsername[index],
                style: contentstyle,
              )),
            );
          },
        ),
      ),
    );
  }

  Widget streamGenerateItem() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UserProfile')
            .where('friends', arrayContainsAny: [user.uid]).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Container();
          } else if (snapshot.hasData) {
            suggestedID.clear();
            suggestedUsername.clear();
            for (var each in snapshot.data!.docs) {
              var data = each.data() as Map<String, dynamic>;
              UserModel userModel = UserModel.fromJson(data);
              String userID = userModel.userId;
              String userName = userModel.username;
              bool notContain = !widget.membersID.contains(userID);
              if (notContain) {
                debugPrint('User ID: $userID');
                suggestedID.add(userID);
                suggestedUsername.add(userName);
              }
            }

            return ListView.builder(
              itemCount: suggestedID.length,
              itemBuilder: (context, index) {
                String userlistID = suggestedID[index];
                String userName = suggestedUsername[index];
                bool isSelect = selectedID.contains(userlistID);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CheckboxListTile(
                    value: isSelect,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedID.add(userlistID);
                          selectedUsername.add(userName);
                        } else {
                          selectedID.remove(userlistID);
                          selectedUsername.remove(userName);
                        }
                      });
                    },
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserListProfile(userId: userlistID, radius: 50),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UserListName(userId: userlistID, fontsize: 15),
                            UserListBio(
                              userId: userlistID,
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      controller: _tcsearch,
      obscureText: false,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
          hintText: 'Search',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 2),
          )),
    );
  }
}
