import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBottomSheet extends StatelessWidget {
  final void Function() onprivateChat;
  final void Function() onGroup;
  const ChatBottomSheet(
      {super.key, required this.onprivateChat, required this.onGroup});

  @override
  Widget build(BuildContext context) {
    final titlestyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    Color color = Theme.of(context).colorScheme.tertiary;
    return SizedBox(
        height: 150,
        child: Column(
          children: [
            ListTile(
                leading: Icon(
                  Icons.person_add,
                  color: color,
                ),
                title: Text(
                  'Add New Friends',
                  style: titlestyle,
                ),
                onTap: onprivateChat),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            ListTile(
                leading: Icon(
                  Icons.group_add,
                  color: color,
                ),
                title: Text('Create New Group', style: titlestyle),
                onTap: onGroup),
          ],
        ));
  }
}
