// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/empty_component/user_empty_comp.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userbio.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_username.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/widget/util/iconback.dart';
import 'package:message_app/screen/widget/util/textfield/search_tf.dart';
import 'package:message_app/screen/tab_bar_screen/group_chat_screen.dart';
import 'package:message_app/screen/tab_bar_screen/private_chat_screen.dart';

import '../widget/loading_component/messageload_comp.dart';
import '../widget/message_component/groupcard_comp.dart';
import '../widget/message_component/usermessage_comp.dart';
import 'chat_page/message/group_msg_page.dart';
import 'chat_page/message/message_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final tcsearchPrivateChat = TextEditingController();
  final tcsearchGroupChat = TextEditingController();

  String searchPrivateChat = '';
  String searchGroupChat = '';

  @override
  Widget build(BuildContext context) {
    final tabstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.tertiary);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: buildAppBar(context),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(tabs: [
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
              ]),
              Expanded(
                  child: TabBarView(
                      children: [buildPrivateChat(), buildGroupChat()]))
            ],
          ),
        ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.0,
      leading: IconBack(
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget buildPrivateChat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchTextField(
          tcsearch: tcsearchPrivateChat,
          onChanged: (value) {
            setState(() {
              searchPrivateChat = value;
            });
          },
        ),
        Expanded(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('UserProfile').where(
              'friends',
              arrayContainsAny: [UserProfileServices.user.uid]).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return buildMessageLoad();
            } else if (snapshot.hasData) {
              final filteredUser = snapshot.data!.docs.where((document) {
                var data = document.data() as Map<String, dynamic>;
                UserModel userModel = UserModel.fromJson(data);
                String userName = userModel.username;
                return userName
                    .toString()
                    .toLowerCase()
                    .contains(searchPrivateChat.toLowerCase());
              }).toList();

              final privateChatList =
                  searchPrivateChat.isEmpty || tcsearchPrivateChat.text == ''
                      ? snapshot.data!.docs
                      : filteredUser;

              if (privateChatList.isEmpty) {
                return const Center(
                    child: UserEmpty(textempty: 'No User Found'));
              } else {
                return ListView.builder(
                  itemCount: privateChatList.length,
                  itemBuilder: (context, index) {
                    UserModel userModel = UserModel.fromJson(
                        privateChatList[index].data() as Map<String, dynamic>);
                    String userlistId = userModel.userId;
                    return buildUserMessageCard(userlistId);
                  },
                );
              }
            } else {
              return buildMessageLoad();
            }
          },
        ))
      ],
    );
  }

  Widget buildUserMessageCard(String userlistId) {
    return FutureBuilder(
      future: ChatServices.getOneToOneGroupModel(userlistId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          GroupModel groupModel = snapshot.data!;
          String lastMessage = groupModel.lastMessage;
          String groupID = groupModel.groupID;
          Timestamp lastTime = groupModel.lastTime;
          return UserMessageCard(
            userlistId: userlistId,
            lastMessage: lastMessage,
            groupID: groupID,
            lastTime: lastTime,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MessagePage(
                  userlistid: userlistId,
                  groupID: groupID,
                ),
              ));
            },
          );
        } else {
          return const MessageLoad();
        }
      },
    );
  }

  Widget buildGroupChat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchTextField(
          tcsearch: tcsearchGroupChat,
          onChanged: (value) {
            setState(() {
              searchGroupChat = value;
            });
          },
        ),
        Expanded(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('UserGroup')
              .where('membersID',
                  arrayContainsAny: [UserProfileServices.user.uid])
              .where('isGroup', isEqualTo: true)
              .orderBy('lastTime', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return buildMessageLoad();
            } else if (snapshot.hasData) {
              final filteredUser = snapshot.data!.docs.where((document) {
                var data = document.data() as Map<String, dynamic>;
                GroupModel groupModel = GroupModel.fromJson(data);
                String groupName = groupModel.groupName;
                return groupName
                    .toString()
                    .toLowerCase()
                    .contains(searchGroupChat.toLowerCase());
              }).toList();
              final groupList =
                  searchGroupChat.isEmpty || tcsearchGroupChat.text == ''
                      ? snapshot.data!.docs
                      : filteredUser;

              if (groupList.isEmpty) {
                return const Center(
                    child: UserEmpty(textempty: 'No Group Found'));
              } else {
                return ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, index) {
                    var data = groupList[index].data() as Map<String, dynamic>;
                    GroupModel groupModel = GroupModel.fromJson(data);
                    String groupID = groupModel.groupID;
                    String groupName = groupModel.groupName;
                    String lastMessage = groupModel.lastMessage;
                    String groupURL = groupModel.groupURL;
                    int groupMembers = groupModel.membersID.length;
                    Timestamp sentAt = groupModel.lastTime;
                    return UserGroupCard(
                      groupName: groupName,
                      lastMessage: lastMessage,
                      groupURL: groupURL,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GroupMessage(
                            groupURL: groupURL,
                            groupName: groupName,
                            groupMembers: groupMembers,
                            groupID: groupID,
                          ),
                        ));
                      },
                      sentAt: sentAt,
                      groupID: groupID,
                    );
                  },
                );
              }
            } else {
              return buildMessageLoad();
            }
          },
        ))
      ],
    );
  }

  Widget temp2() {
    return Expanded(
      child: FutureBuilder(
        future: UserProfileServices.fetchUserGroupsSearch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Container();
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var eachdata = snapshot.data![index];
                return ListTile(
                  title: Text(eachdata.toString()),
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

  Widget buildMessageLoad() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return MessageLoad();
      },
    );
  }
}
