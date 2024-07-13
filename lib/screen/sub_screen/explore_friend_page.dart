import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/mainscreen.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/buttons_component/requestbtn_comp.dart';
import 'package:message_app/screen/widget/empty_component/user_empty_comp.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userbio.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_username.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/widget/util/textfield/search_tf.dart';

import '../../services/request_services.dart';
import '../../services/userprofile_services.dart';
import '../../constant/snakbar.dart';
import '../widget/loading_component/error_comp.dart';
import '../widget/loading_component/load_comp.dart';
import '../widget/user_component/usersearch_comp.dart';

class ExploreFriendPage extends StatefulWidget {
  ExploreFriendPage({super.key});

  @override
  State<ExploreFriendPage> createState() => _ExploreFriendPage();
}

class _ExploreFriendPage extends State<ExploreFriendPage> {
  final _tcsearch = TextEditingController();
  UserModel? userModel;
  final user = FirebaseAuth.instance.currentUser!;
  String searchName = '';

  //User Default Field
  String currentuseremail = '';
  String currentusername = '';
  String currentuserprofilepicture = '';
  String currentuserbio = '';
  int currentusernumber = 0;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    try {
      userModel = await UserProfileServices.getUserDetail(user.uid);
      setState(() {
        currentuseremail = userModel!.useremail;
        currentusername = userModel!.username;
        currentuserprofilepicture = userModel!.userprofile;
        currentuserbio = userModel!.userbio;
        currentusernumber = userModel!.usernumber;
      });
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(appbarstyle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Explore',
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SearchTextField(
            tcsearch: _tcsearch,
            onChanged: (value) {
              setState(() {
                searchName = value;
              });
            },
          ),
          buildUserList()
        ],
      ),
    );
  }

  AppBar buildAppBar(TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.tertiary,
          )),
      centerTitle: true,
      title: Text(
        'Search',
        style: appbarstyle,
      ),
    );
  }

  Widget buildUserList() {
    return Expanded(
        child: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .where('userId', isNotEqualTo: user.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingUI());
        } else if (snapshot.hasError) {
          return Center(
              child: ErrorUI(
            error: snapshot.error.toString(),
          ));
        } else if (snapshot.hasData) {
          final filteredUser = snapshot.data!.docs.where((document) {
            var data = document.data() as Map<String, dynamic>;
            UserModel userModel = UserModel.fromJson(data);
            String userName = userModel.username;
            return userName
                .toString()
                .toLowerCase()
                .contains(searchName.toLowerCase());
          }).toList();

          final userList = searchName.isEmpty || _tcsearch.text.isEmpty
              ? snapshot.data!.docs
              : filteredUser;

          if (userList.isEmpty) {
            return const Center(child: UserEmpty(textempty: 'No User Found'));
          } else {
            return ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                var data = userList[index].data() as Map<String, dynamic>;
                UserModel userModel = UserModel.fromJson(data);
                String userID = userModel.userId;
                String userProfile = userModel.userprofile;
                String userName = userModel.username;
                String userBio = userModel.userbio;
                return buildUserSearchCard(
                    userID, userName, userProfile, userBio);
              },
            );
          }
        } else {
          return const Center(child: LoadingUI());
        }
      },
    ));
  }

  Widget buildUserSearchCard(
      String userID, String userName, String userProfile, String userBio) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: EachUserProfile(
            userProfile: userProfile,
            radius: 50,
          ),
          title: EachUserName(
            userName: userName,
            fontSize: 15,
          ),
          subtitle: EachUserBio(userBio: userBio),
          trailing: SizedBox(
            height: 40,
            child: RequestButton(
              userlistId: userID,
              press: () async {
                String groupID = await ChatServices.getOneToOneGroupID(userID);
                debugPrint('GROUP ID: $groupID');
                showDialogDelete(context, groupID, userID);
              },
            ),
          ),
        ));
  }

  void showDialogDelete(
      BuildContext context, String groupID, String userlistId) {
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                'Delete Friend',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure want to delete ?',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'All your chats and photos will be delete',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    RequestServices.removeFriend(userlistId, groupID);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
