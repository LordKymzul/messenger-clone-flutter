import 'package:flutter/material.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

class UserInfo extends StatelessWidget {
  final String userId;
  const UserInfo({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserListProfile(userId: userId, radius: 40),
        const SizedBox(
          width: 10,
        ),
        Expanded(child: UserListName(userId: userId, fontsize: 18)),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
