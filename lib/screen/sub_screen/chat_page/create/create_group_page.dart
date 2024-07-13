import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/screen/widget/loading_component/loadingdialog_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userbio_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:message_app/screen/widget/util/bottom_sheet/pick_bs.dart';

class CreateGroupPage extends StatefulWidget {
  CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _tcname = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  List<String> selectedItems = [];
  List<String> usernameItems = [];
  File? image;
  UploadTask? uploadTask;
  var imagepick;
  bool isLoading = false;

  @override
  void initState() {
    selectedItems.add(user.uid);
    debugPrint('Added ${user.uid}');
    super.initState();
  }

  @override
  void dispose() {
    selectedItems.remove(user.uid);
    debugPrint('Remove ${user.uid}');
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedimage = await ImagePicker().pickImage(source: source);
      if (pickedimage == null) {
        return;
      }

      setState(() {
        image = File(pickedimage.path);
        imagepick = pickedimage;
      });
    } on PlatformException catch (e) {
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);

      debugPrint(e.toString());
    }
  }

  Future<void> uploadGroupURL(String groupName, List<String> sItems) async {
    setState(() {
      isLoading = true;
    });
    try {
      final file = File(imagepick!.path!);
      final ref =
          FirebaseStorage.instance.ref().child('GroupURL').child(groupName);

      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      ChatServices.createdGroup(
          sItems, '', _tcname.text.trim(), true, urlDownload);

      Navigator.pop(context);
    } catch (e) {
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void togglebottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24), topLeft: Radius.circular(24))),
      builder: (context) {
        return PickButtomSheet(
          onCamera: () {
            pickImage(ImageSource.camera);
          },
          onGallery: () {
            pickImage(ImageSource.gallery);
          },
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return LoadingDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final contentstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(context, appbarstyle),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(hintstyle, context),
            const SizedBox(
              height: 20,
            ),
            if (usernameItems.isNotEmpty) listMembers(contentstyle),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members',
                  style: titlestyle,
                ),
                Text(
                  'Create a chat with more than 2 people.',
                  style: subtitlestyle,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            //generateItems()
            streamGenerateItem()
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return AppBar(
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
      actions: [
        isLoading
            ? SpinKitFadingCircle(
                size: 30,
                color: Theme.of(context).colorScheme.secondary,
              )
            : IconButton(
                onPressed: () {
                  String groupName = _tcname.text.trim();

                  if (groupName.isEmpty) {
                    SnackBarUtil.showSnackBar(
                        'Please Enter Group Name', Colors.red);
                  } else {
                    if (imagepick == null) {
                      SnackBarUtil.showSnackBar(
                          'Please Upload Group Profile Picture', Colors.red);
                    } else {
                      if (selectedItems.length < 3) {
                        SnackBarUtil.showSnackBar(
                            'Group Chat must more than 2 people', Colors.red);
                      } else {
                        uploadGroupURL(groupName, selectedItems);
                      }
                    }
                  }
                },
                icon: Icon(
                  Icons.done,
                  color: Theme.of(context).colorScheme.tertiary,
                ))
      ],
      title: Text(
        'New Group',
        style: appbarstyle,
      ),
    );
  }

  Widget Header(TextStyle hintstyle, BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            togglebottomsheet(context);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: image != null
                ? Image.file(
                    image!,
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey,
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/camera.png',
                      height: 30,
                      width: 30,
                    ),
                  ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: TextField(
            controller: _tcname,
            obscureText: false,
            decoration: InputDecoration(
                hintText: 'Group Subject',
                hintStyle: hintstyle,
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        )
      ],
    );
  }

  Widget listMembers(TextStyle contentstyle) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: usernameItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Theme.of(context).colorScheme.secondary),
              child: Center(
                  child: Text(
                usernameItems[index],
                style: contentstyle,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget streamGenerateItem() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UserProfile')
            .where('friends', arrayContainsAny: [user.uid]).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Container();
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var userData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String userlistID = userData['userId'];
                String userName = userData['username'];

                bool isSelect = selectedItems.contains(userlistID);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: CheckboxListTile(
                    value: isSelect,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedItems.add(userlistID);
                          usernameItems.add(userName);
                        } else {
                          selectedItems.remove(userlistID);
                          usernameItems.remove(userName);
                        }
                      });
                    },
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserListProfile(userId: userlistID, radius: 50),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UserListName(userId: userlistID, fontsize: 15),
                            UserListBio(
                              userId: userlistID,
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
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
}
