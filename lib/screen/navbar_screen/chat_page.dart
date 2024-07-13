import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/loading_component/error_comp.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';
import 'package:message_app/screen/widget/loading_component/messageload_comp.dart';
import 'package:message_app/screen/widget/loading_component/userbubble_load.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/user_bubble/user_bubble_online_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:message_app/screen/widget/message_component/usermessage_comp.dart';
import 'package:message_app/screen/widget/util/bottom_sheet/chat_bs.dart';
import 'package:message_app/screen/widget/util/date/date.dart';
import 'package:message_app/screen/sub_screen/chat_page/create/create_group_page.dart';
import 'package:message_app/screen/sub_screen/chat_page/message/message_page.dart';
import 'package:message_app/screen/sub_screen/search_page.dart';
import 'package:message_app/screen/tab_bar_screen/group_chat_screen.dart';
import 'package:message_app/screen/tab_bar_screen/private_chat_screen.dart';

import '../sub_screen/explore_friend_page.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final _tcsearch = TextEditingController();

  final user = FirebaseAuth.instance.currentUser!;

  String tempcontent =
      'This blog post covers 5 things you should take care of when using the BottomNavigationBar to enhance the user experience.';

  String masonary2 =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Mona_Lisa-restored.jpg/1200px-Mona_Lisa-restored.jpg';

  void buildDialog(
      BuildContext context, TextStyle titlestyle, TextStyle subtitlestyle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a group chat',
                style: titlestyle,
              ),
              Text(
                'Create a chat with more than 2 people.',
                style: subtitlestyle,
              )
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name',
                style: titlestyle,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.tertiary);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24))),
            builder: (context) {
              return ChatBottomSheet(
                onprivateChat: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExploreFriendPage(),
                  ));
                },
                onGroup: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateGroupPage(),
                  ));
                },
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Header(titlestyle, subtitlestyle),
                  ),
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    shape: Border(
                        bottom: BorderSide(
                            color: Color(0xFFAAAAAA).withOpacity(1), width: 1)),
                    bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(0),
                        child: TabBar(
                            unselectedLabelColor: Colors.grey,
                            labelColor: Theme.of(context).colorScheme.tertiary,
                            indicatorColor:
                                Theme.of(context).colorScheme.secondary,
                            indicatorWeight: 5,
                            tabs: [
                              Tab(
                                child: Text(
                                  'Chat',
                                  style: tabstyle,
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Group',
                                  style: tabstyle,
                                ),
                              )
                            ])),
                  )
                ];
              },
              body: TabBarView(
                children: [PrivateChat(), GroupChat()],
              ))),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/messenger.png',
        height: 30,
        width: 30,
      ),
      leading: Icon(
        Icons.abc,
        color: Theme.of(context).colorScheme.background,
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(),
              ));
            },
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.tertiary,
            )),
      ],
    );
  }

  Widget Header(TextStyle titlestyle, subtitlestyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back',
            style: titlestyle,
          ),
          FutureBuilder<UserModel?>(
            future: UserProfileServices.getUserDetail(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserModel userModel = snapshot.data!;
                String userName = userModel.username;
                return Text(
                  userName,
                  style: subtitlestyle,
                );
              } else {
                return Text(
                  'null',
                  style: subtitlestyle,
                );
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
          bubbleUserOnline()
        ],
      ),
    );
  }

  Widget bubbleUserOnline() {
    return SizedBox(
      height: 100,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UserProfile')
            .where('friends', arrayContainsAny: [user.uid]).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return bubbleonlineLoad();
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return bubbleonlineLoad();
          } else if (snapshot.hasData) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String userProfile = data['userprofile'];
                String userName = data['username'];
                bool isOnline = data['is_online'];
                return UserBubbleOnline(
                    userProfile: userProfile,
                    userName: userName,
                    isOnline: isOnline);
              },
            );
          } else {
            return bubbleonlineLoad();
          }
        },
      ),
    );
  }

  Widget bubbleUserOnline1() {
    return SizedBox(
        height: 100,
        width: double.infinity,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return UserBubbleOnline(
                userProfile: masonary2, userName: 'Hakim', isOnline: true);
          },
        ));
  }

  Widget ContainerSearch(BuildContext context, TextStyle hintStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Theme.of(context).colorScheme.primary),
        child: TextField(
          controller: _tcsearch,
          obscureText: false,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              hintText: 'Search your friend here',
              hintStyle: hintStyle,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent))),
        ),
      ),
    );
  }

  Widget bubbleonlineLoad() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: 70,
          width: 70,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
        );
      },
    );
  }
}
