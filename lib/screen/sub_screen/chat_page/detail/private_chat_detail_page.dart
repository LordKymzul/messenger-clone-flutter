import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:message_app/screen/sub_screen/chat_page/detail/allphoto_detail_page.dart';

import '../../../widget/loading_component/error_comp.dart';

class PrivateChatDetail extends StatefulWidget {
  final String userlistID, groupID;
  PrivateChatDetail(
      {super.key, required this.userlistID, required this.groupID});

  @override
  State<PrivateChatDetail> createState() => _PrivateChatDetailState();
}

class _PrivateChatDetailState extends State<PrivateChatDetail> {
  final user = FirebaseAuth.instance.currentUser!;
  String userName = '';
  String userBio = '';
  String userEmail = '';
  int userNumber = 0;
  String userID = '';
  List<dynamic> photosList = [];

  @override
  void initState() {
    fetchUserDetail();
    super.initState();
  }

  Future<void> fetchUserDetail() async {
    try {
      UserModel? userModel =
          await UserProfileServices.getUserDetail(widget.userlistID);
      setState(() {
        userName = userModel!.username;
        userBio = userModel.userbio;
        userEmail = userModel.useremail;
        userNumber = userModel.usernumber;
        userID = userModel.userId;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    fetchUserDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.w600);
    final content1style = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final subcontentstyle = GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    final contentstyle = GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CustomScrollView(
          slivers: [
            buildAppBar(context, appbarstyle),
            SliverList(
                delegate: SliverChildListDelegate([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildUserBio(titlestyle, contentstyle),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  buildUserInformation(titlestyle, contentstyle),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  userMedia(titlestyle, subtitlestyle, context),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Common Groups',
                      style: titlestyle,
                    ),
                  ),
                ],
              ),
            ])),
            userGroups(
                titlestyle, contentstyle, subcontentstyle, widget.userlistID),
            buildBottom()
          ],
        ));
  }

  SliverAppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 250,
      automaticallyImplyLeading: false,
      elevation: 0.5,
      backgroundColor: Theme.of(context).colorScheme.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          userName,
          style: GoogleFonts.poppins(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600),
        ),
        background: FutureBuilder(
          future: UserProfileServices.getUserDetail(widget.userlistID),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = snapshot.data!;
              String userProfile = userModel.userprofile;
              return Image.network(
                userProfile,
                fit: BoxFit.cover,
              );
            } else {
              return Image.asset(
                'assets/messenger.png',
                fit: BoxFit.contain,
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildUserBio(TextStyle titlestyle, TextStyle contentstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: titlestyle,
          ),
          Text(
            userBio,
            style: contentstyle,
          ),
        ],
      ),
    );
  }

  Widget buildUserInformation(TextStyle titlestyle, TextStyle contentstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: titlestyle,
          ),
          const SizedBox(
            height: 10,
          ),
          buildSubUserInformation(
              'Email', userEmail, Icons.email, contentstyle),
          const SizedBox(
            height: 10,
          ),
          buildSubUserInformation('Number Phone', '0${userNumber.toString()}',
              Icons.phone, contentstyle),
          const SizedBox(
            height: 10,
          ),
          buildSubUserInformation(
              'User ID', userID, Icons.person, contentstyle),
        ],
      ),
    );
  }

  Widget buildSubUserInformation(
      String title, String information, IconData icon, TextStyle contentstyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              information,
              style: contentstyle,
            ),
            Icon(
              icon,
              color: Theme.of(context).colorScheme.tertiary,
            )
          ],
        ),
      ],
    );
  }

  Widget userMedia(
      TextStyle titlestyle, TextStyle subtitlestyle, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photos',
                style: titlestyle,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AllPhotoDetail(
                      allmessageURL: photosList,
                    ),
                  ));
                },
                child: Text(
                  'See all',
                  style: subtitlestyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('UserGroup')
              .doc(widget.groupID)
              .collection('Messages')
              .where('isText', isEqualTo: false)
              .orderBy('sendAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return photoLoad();
            } else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return ErrorUI(error: snapshot.error.toString());
            } else if (snapshot.hasData) {
              for (var eachDoc in snapshot.data!.docs) {
                var data = eachDoc.data() as Map<String, dynamic>;
                MessageModel messageModel = MessageModel.fromJson(data);
                List<dynamic> messageURL = messageModel.messageURL;
                photosList.addAll(messageURL);
              }
              if (snapshot.data!.docs.isEmpty) {
                return SizedBox(
                    height: 50,
                    child: Center(
                        child: Text(
                      'No Photo yet',
                      style: titlestyle,
                    )));
              } else {
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photosList.length,
                    itemBuilder: (context, index) {
                      var eachPhoto = photosList[index];
                      return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: buildPhotoList(eachPhoto));
                    },
                  ),
                );
              }
            } else {
              return photoLoad();
            }
          },
        )
      ],
    );
  }
}

Widget userGroups(TextStyle titlestyle, TextStyle contentstyle,
    TextStyle subcontentstyle, String userlistID) {
  return FutureBuilder<List<GroupModel>>(
    future: ChatServices.groupCommonsData(userlistID),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SliverToBoxAdapter(child: Center(child: LoadingUI()));
      } else if (snapshot.hasError) {
        debugPrint(snapshot.error.toString());
        return Center(
            child: SliverToBoxAdapter(
          child: ErrorUI(
            error: snapshot.error.toString(),
          ),
        ));
      } else if (snapshot.hasData) {
        List<GroupModel> commonGroups = snapshot.data!;
        return SliverList(
            delegate: SliverChildBuilderDelegate(
                childCount: commonGroups.length, (context, index) {
          var eachElement = commonGroups[index];
          String groupName = eachElement.groupName;
          String groupURL = eachElement.groupURL;
          String groupAdmin = eachElement.createdBy;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(groupURL),
                  radius: 30,
                ),
                title: Text(
                  groupName,
                  style: contentstyle,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      'Created By',
                      style: subcontentstyle,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    UserListName(userId: groupAdmin, fontsize: 12)
                  ],
                )),
          );
        }));
      } else {
        return const SliverToBoxAdapter(child: Center(child: LoadingUI()));
      }
    },
  );
}

Widget buildBottom() {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 20, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remove Friend',
            style: GoogleFonts.poppins(
                fontSize: 15, color: Colors.red, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'You wont receive any messages or media from this user after you remove friend.',
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    ),
  );
}

Widget buildPhotoList(String photo) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: photo == ''
        ? Image.asset('assets/userchat.png', fit: BoxFit.cover)
        : CachedNetworkImage(
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            imageUrl: photo,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
          ),
  );
}

Widget photoLoad() {
  return SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.grey),
            ));
      },
    ),
  );
}
