import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/services/status_services.dart';
import 'package:message_app/constant/snakbar.dart';

import '../../widget/util/bottom_sheet/pick_bs.dart';

class UploadStatusPage extends StatefulWidget {
  UploadStatusPage({super.key});

  @override
  State<UploadStatusPage> createState() => _UploadStatusPageState();
}

class _UploadStatusPageState extends State<UploadStatusPage> {
  final _tccaption = TextEditingController();
  UploadTask? uploadTask;
  File? image;
  bool isLoading = false;
  var imagepick;
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> pickImage(ImageSource source) async {
    try {
      final imagepicked = await ImagePicker().pickImage(source: source);
      if (imagepicked == null) {
        return;
      }

      setState(() {
        image = File(imagepicked.path);
        imagepick = imagepicked;
      });
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  Future<void> uploadToFirebaseStorage(String caption) async {
    setState(() {
      isLoading = true;
    });
    try {
      final file = File(imagepick!.path!);
      final ref = FirebaseStorage.instance
          .ref()
          .child('UserStatus')
          .child(user.uid)
          .child(imagepick!.name);

      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      debugPrint(urlDownload);

      StatusServices.uploadStatus(urlDownload, imagepick!.name, caption);

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
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

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final buttonstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey);
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.tertiary);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(context, appbarstyle),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            pickImageButton(),
            const SizedBox(
              height: 10,
            ),
            const Spacer(),
            CaptionField(context, hintstyle)
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Upload Status',
        style: appbarstyle,
      ),
    );
  }

  Widget pickImageButton() {
    return MaterialButton(
      color: Theme.of(context).colorScheme.primary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        togglebottomsheet(context);
      },
      child: Center(
          child: image != null
              ? Image.file(
                  image!,
                )
              : Image.asset('assets/userchat.png')),
    );
  }

  Widget CaptionField(BuildContext context, TextStyle hintStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: _tccaption,
                obscureText: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: hintStyle,
                    border: InputBorder.none),
              ),
            ),
            GestureDetector(
              onTap: () {
                String caption = _tccaption.text.trim();
                uploadToFirebaseStorage(caption);
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.background,
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
