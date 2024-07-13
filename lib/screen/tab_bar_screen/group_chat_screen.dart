import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/screen/widget/empty_component/chat_empty_comp.dart';
import 'package:message_app/screen/widget/message_component/groupcard_comp.dart';
import 'package:message_app/screen/sub_screen/chat_page/message/group_msg_page.dart';

import '../widget/loading_component/messageload_comp.dart';

class GroupChat extends StatelessWidget {
  GroupChat({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ContainerGroup());
  }

  Widget ContainerGroup() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContainsAny: [user.uid])
          .where('isGroup', isEqualTo: true)
          .orderBy('lastTime', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return messageLoad();
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return messageLoad();
        } else if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: ChatEmpty(
                    textempty: 'You are not a member of any groups.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String groupName = data['groupName'];
                String lastMessage = data['lastMessage'];
                String groupURL = data['groupURL'];
                String groupID = data['groupID'];
                Timestamp sentAt = data['lastTime'];
                List<dynamic> membersLength = [];
                if (data.containsKey('membersID')) {
                  List<dynamic> membersID = data['membersID'];
                  membersLength.addAll(membersID);
                }

                int groupMembers = membersLength.length;

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
          return messageLoad();
        }
      },
    );
  }

  Widget messageLoad() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return MessageLoad();
      },
    );
  }
}
