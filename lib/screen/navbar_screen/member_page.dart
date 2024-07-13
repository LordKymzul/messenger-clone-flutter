import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/tab_bar_screen/friend_screen.dart';
import 'package:message_app/screen/tab_bar_screen/request_screen.dart';

class MemberPage extends StatelessWidget {
  MemberPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 24,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final subheaderstyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    final tabstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.tertiary);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: buildAppBar(context, appbarstyle),
        body: DefaultTabController(
            length: 2,
            child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: buildHeader(titlestyle, subheaderstyle),
                    ),
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      shape: Border(
                          bottom: BorderSide(
                              color: Color(0xFFAAAAAA).withOpacity(1),
                              width: 1)),
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(0),
                          child: TabBar(
                              unselectedLabelColor: Colors.grey,
                              labelColor:
                                  Theme.of(context).colorScheme.tertiary,
                              indicatorColor:
                                  Theme.of(context).colorScheme.secondary,
                              indicatorWeight: 5,
                              tabs: [
                                Tab(
                                  child: Text(
                                    'Friends',
                                    style: tabstyle,
                                  ),
                                ),
                                Tab(child: buildTabRequest(tabstyle, context)),
                              ])),
                    )
                  ];
                },
                body: TabBarView(
                  children: [Friend(), Request()],
                ))));
  }

  AppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'Friends',
        style: appbarstyle,
      ),
    );
  }

  Widget buildHeader(TextStyle titlestyle, TextStyle subheaderstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Friends',
                style: titlestyle,
              ),
              fetchFriendsLength(subheaderstyle)
            ],
          ),
          buildProfilePicture()
        ],
      ),
    );
  }

  Widget buildProfilePicture() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FutureBuilder(
        future: UserProfileServices.getUserDetail(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserModel userModel = snapshot.data!;
            String userProfile = userModel.userprofile;
            return EachUserProfile(userProfile: userProfile, radius: 60);
          } else {
            return Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey),
            );
          }
        },
      ),
    );
  }

  Widget fetchFriendsLength(TextStyle subheaderstyle) {
    return FutureBuilder(
      future: UserProfileServices.getUserDetail(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel userModel = snapshot.data!;
          List<String> friendsList = userModel.friends;
          int friendLength = friendsList.length;
          if (friendsList.isEmpty) {
            return Text(
              '0 Friend',
              style: subheaderstyle,
            );
          } else {
            return Text(
              '$friendLength Friends',
              style: subheaderstyle,
            );
          }
        } else {
          return Text(
            '0 Friend',
            style: subheaderstyle,
          );
        }
      },
    );
  }

  Widget buildTabRequest(TextStyle tabstyle, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Request',
          style: tabstyle,
        ),
        const SizedBox(
          width: 5,
        ),
        buildNumOfRequest()
      ],
    );
  }

  Widget buildNumOfRequest() {
    return FutureBuilder(
      future: UserProfileServices.getUserDetail(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel userModel = snapshot.data!;
          int numRequest = userModel.numRequest;
          if (numRequest == 0) {
            return const SizedBox(
              height: 1,
              width: 1,
            );
          } else {
            return Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary),
              child: Center(
                  child: Text(
                numRequest.toString(),
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              )),
            );
          }
        } else {
          return const SizedBox(
            height: 1,
            width: 1,
          );
        }
      },
    );
  }
}
