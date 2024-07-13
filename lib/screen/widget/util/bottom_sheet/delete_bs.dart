import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteButtomSheet extends StatelessWidget {
  final Function() onTapDelete;
  final String userlistId;
  DeleteButtomSheet(
      {super.key, required this.onTapDelete, required this.userlistId});

  final user = FirebaseAuth.instance.currentUser!;
  bool isUser() {
    if (user.uid == userlistId) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textstyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.volume_off,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              title: Text(
                'Mute Status',
                style: textstyle,
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(
                isUser() ? Icons.delete_forever_outlined : Icons.abc,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              title: Text(
                isUser() ? 'Delete' : 'Nothing to do',
                style: textstyle,
              ),
              onTap: isUser()
                  ? onTapDelete
                  : () {
                      debugPrint('nothng todo');
                    },
            ),
          ],
        ),
      ),
    );
  }
}
