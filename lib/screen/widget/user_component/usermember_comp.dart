import 'package:flutter/material.dart';
import 'package:message_app/screen/widget/user_component/user_util/userbio_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

class UserMember extends StatelessWidget {
  final String userlistId;
  void Function() onTap;
  UserMember({super.key, required this.userlistId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              leading: UserListProfile(
                userId: userlistId,
                radius: 25,
              ),
              title: UserListName(
                userId: userlistId,
                fontsize: 15,
              ),
              subtitle: UserListBio(userId: userlistId),
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.chat_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined))
            ],
          )
        ],
      ),
    );
  }
}
