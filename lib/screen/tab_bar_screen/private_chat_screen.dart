import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/empty_component/chat_empty_comp.dart';
import 'package:message_app/screen/widget/util/textfield/search_tf.dart';

import '../widget/loading_component/messageload_comp.dart';
import '../widget/message_component/usermessage_comp.dart';
import '../sub_screen/chat_page/message/message_page.dart';

class PrivateChat extends StatelessWidget {
  PrivateChat({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  final tcsearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return buildMessageList();
  }

  Widget buildMessageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContainsAny: [user.uid])
          .where('isGroup', isEqualTo: false)
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
                child: ChatEmpty(textempty: 'No conversations to display.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                String groupID = data['groupID'];
                String lastMessage = data['lastMessage'];
                Timestamp lastTime = data['lastTime'];
                // Check if 'membersID' field exists and is a list
                if (data.containsKey('membersID') &&
                    data['membersID'] is List) {
                  List<dynamic> membersList = data['membersID'];

                  // Filter out the current user's ID (user.uid)
                  List<dynamic> filteredMembersList = membersList
                      .where((memberId) => memberId != user.uid)
                      .toList();

                  // Iterate through the elements in the 'membersID' array

                  return Column(
                    children: filteredMembersList.map<Widget>((memberId) {
                      // Do something with each member ID (e.g., display it)

                      return UserMessageCard(
                        userlistId: memberId,
                        lastMessage: lastMessage,
                        groupID: groupID,
                        lastTime: lastTime,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MessagePage(
                              userlistid: memberId,
                              groupID: groupID,
                            ),
                          ));
                        },
                      );
                    }).toList(),
                  );
                }
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
