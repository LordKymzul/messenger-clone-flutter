import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/request_services.dart';
import 'package:message_app/screen/widget/buttons_component/requestbtn_comp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSearch extends StatefulWidget {
  final String currentuseremail,
      currentusername,
      currentuserprofilepicture,
      currentuserbio;
  final int currentusernumber;
  final String userId, useremail, username, userprofile, userbio;
  final int usernumber;
  UserSearch(
      {super.key,
      required this.userId,
      required this.useremail,
      required this.username,
      required this.userprofile,
      required this.userbio,
      required this.usernumber,
      required this.currentuseremail,
      required this.currentusername,
      required this.currentuserprofilepicture,
      required this.currentuserbio,
      required this.currentusernumber});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  late bool isButtonEnabled;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = false;
    loadButtonState();
  }

  void loadButtonState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isButtonEnabled = prefs.getBool('isButtonEnabled') ?? false;
    });
  }

  void saveButtonState(bool isEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isButtonEnabled', isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final namestyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final biostyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.userprofile),
            radius: 25,
          ),
          title: Text(widget.username, style: namestyle),
          subtitle: Text(
            widget.userbio,
            style: biostyle,
          ),
          trailing: RequestButton(
            userlistId: widget.userId,
            press: () {},
          )),
    );
  }
}
