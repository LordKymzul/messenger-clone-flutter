import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/auth/verifyemail_page.dart';
import 'package:message_app/mainscreen.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';

import '../../services/userprofile_services.dart';
import '../../constant/snakbar.dart';

class SetupProfilePage extends StatefulWidget {
  final String username, userprofile, userbio;
  final int usernumber;
  SetupProfilePage(
      {super.key,
      required this.username,
      required this.userprofile,
      required this.userbio,
      required this.usernumber});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _tcusername = TextEditingController();
  final _tcbio = TextEditingController();
  final _tcnumberphone = TextEditingController();
  File? image;
  var imagepicked;
  UploadTask? uploadTask;
  UserProfileServices userProfileServices = UserProfileServices();
  bool isLoading = false;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _tcusername.text = widget.username;
    _tcbio.text = widget.userbio;
    _tcnumberphone.text = widget.usernumber.toString();
  }

  Future<void> pickImage(ImageSource source) async {
    setState(() {
      isSelected = true;
    });
    try {
      final pickedimage = await ImagePicker().pickImage(source: source);
      if (pickedimage == null) {
        return;
      }
      final imagetemp = pickedimage;
      setState(() {
        image = File(imagetemp.path);
        imagepicked = pickedimage;
      });
    } on PlatformException catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  Future<void> uploadImage(
      final imagepick, String username, String userbio, int usernumber) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (imagepick == null) {
        UserProfileServices.updateUserProfile(
            username, userbio, usernumber, '', true);
      } else {
        final file = File(imagepick!.path!);
        final ref =
            FirebaseStorage.instance.ref().child('UserProfile').child(user.uid);
        uploadTask = ref.putFile(file);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        debugPrint(urlDownload);

        UserProfileServices.updateUserProfile(
            username, userbio, usernumber, urlDownload, false);
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MainScreen(),
      ));
      SnackBarUtil.showSnackBar('Succesfully updated profile', Colors.green);
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    } finally {
      setState(() {
        isLoading = false;
        isSelected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final titlestyle1 = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final titlestyle2 = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey);
    final buttonstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.tertiary,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(titlestyle1, titlestyle2),
              const SizedBox(
                height: 40,
              ),
              UserProfile(context),
              const SizedBox(
                height: 40,
              ),
              InputField(context, hintstyle),
              const SizedBox(
                height: 40,
              ),
              Button(context, buttonstyle)
            ],
          ),
        ),
      ),
    );
  }

  Widget Header(TextStyle textstyle1, TextStyle textstyle2) {
    return Column(
      children: [
        Text(
          'Edit Your Profile',
          style: textstyle1,
        ),
        Text(
          'Dont worry, only you can see your personal information',
          style: textstyle2,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget UserProfile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pickImage(ImageSource.gallery);
      },
      child: Stack(
        children: [
          isSelected
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(64),
                  child: image != null
                      ? Image.file(
                          image!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/userchat.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                )
              : EachUserProfile(userProfile: widget.userprofile, radius: 100),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary),
                child: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.background,
                ),
              ))
        ],
      ),
    );
  }

  Widget InputField(BuildContext context, TextStyle hintstyle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary),
          child: TextField(
            controller: _tcusername,
            obscureText: false,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: hintstyle,
                prefixIcon: const Icon(
                  Icons.person_outline_outlined,
                  color: Colors.grey,
                ),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary),
          child: TextField(
            controller: _tcbio,
            obscureText: false,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
                hintText: 'Bio',
                hintStyle: hintstyle,
                prefixIcon: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.grey,
                ),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary),
          child: TextField(
            controller: _tcnumberphone,
            obscureText: false,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: hintstyle,
                prefixIcon: const Icon(
                  Icons.numbers_outlined,
                  color: Colors.grey,
                ),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        )
      ],
    );
  }

  Widget Button(BuildContext context, TextStyle buttonstyle) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      onPressed: () {
        String username = _tcusername.text;
        String userbio = _tcbio.text;
        int usernumber = int.parse(_tcnumberphone.text);
        uploadImage(imagepicked, username, userbio, usernumber);
      },
      child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  'Save',
                  style: buttonstyle,
                )),
    );
  }
}
