import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/screen/widget/empty_component/user_empty_comp.dart';

import '../widget/loading_component/error_comp.dart';
import '../widget/loading_component/messageload_comp.dart';
import '../widget/user_component/userrequest_comp.dart';

class Request extends StatelessWidget {
  Request({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: buildRequestList(),
    );
  }

  Widget buildRequestList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .where('statusFriend', isEqualTo: 'Requested')
          .where('statusProcess', isEqualTo: 'Receiver')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildUserLoad();
        } else if (snapshot.hasError) {
          return Center(
              child: ErrorUI(
            error: snapshot.error.toString(),
          ));
        } else if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: UserEmpty(
                textempty: 'No one has requested to be your friend yet.',
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return UserRequest(
                  userlistId: data['userId'],
                );
              },
            );
          }
        } else {
          return buildUserLoad();
        }
      },
    );
  }

  Widget buildUserLoad() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return const MessageLoad();
      },
    );
  }
}
