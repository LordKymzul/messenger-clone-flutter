import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/message_services.dart';
import 'package:message_app/services/status2_services.dart';
import 'package:message_app/services/status_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MediaPage extends StatefulWidget {
  var image;
  var imagepick;
  final String groupID;
  final bool isStatus;
  final List<XFile?> selectedImages;
  final List<dynamic> selectedImagesNames;

  MediaPage(
      {super.key,
      required this.image,
      required this.imagepick,
      required this.groupID,
      required this.isStatus,
      required this.selectedImages,
      required this.selectedImagesNames});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _tccaption = TextEditingController();
  UploadTask? uploadTask;
  bool isLoading = false;
  final pc = PageController();
  List<dynamic> listUrlDownloads = [];

  Future<void> uploadToFirebaseStorage(String caption) async {
    setState(() {
      isLoading = true;
    });
    try {
      for (var eachImage in widget.selectedImages) {
        final file = File(eachImage!.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('UserMessage')
            .child(user.uid)
            .child(eachImage.name);

        uploadTask = ref.putFile(file);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        debugPrint(urlDownload);
        listUrlDownloads.add(urlDownload);
      }

      if (widget.isStatus) {
        final file = File(widget.imagepick!.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('UserStatus')
            .child(user.uid)
            .child(widget.imagepick.name);

        uploadTask = ref.putFile(file);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        debugPrint(urlDownload);
        Status2Services.uploadStatus(
            urlDownload, widget.imagepick!.name, caption);
      } else {
        MessageServices.sendMessage(widget.groupID, caption, listUrlDownloads,
            widget.selectedImagesNames, false);
      }

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.selectedImages.clear();
    widget.selectedImagesNames.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double myheight = MediaQuery.of(context).size.height;
    double mywidth = MediaQuery.of(context).size.width;
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.tertiary);
    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Stack(
            children: [
              buildStatusOrMessage(myheight, mywidth),
              buildHeaderandCaptionField(hintstyle)
            ],
          )),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
    );
  }

  Widget buildStatusOrMessage(double myheight, double mywidth) {
    if (widget.isStatus == true) {
      return buildSingleImageUpload(widget.image != null, myheight, mywidth);
    } else {
      return PageView.builder(
        controller: pc,
        itemCount: widget.selectedImages.length,
        itemBuilder: (context, index) {
          var eachElemet = widget.selectedImages[index];
          var imageURL = eachElemet!.path;

          return Image.file(File(imageURL));
        },
      );
    }
  }

  Widget buildSingleImageUpload(
      bool isImagNotNull, double myheight, double mywidth) {
    return isImagNotNull
        ? Image.file(
            widget.image,
            height: myheight,
            width: mywidth,
            fit: BoxFit.contain,
          )
        : Image.asset(
            'assets/messenger.png',
            height: myheight,
            width: mywidth,
            fit: BoxFit.contain,
          );
  }

  Widget buildHeaderandCaptionField(TextStyle hintstyle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              )
            ],
          ),
          const Spacer(),
          Align(
              alignment: Alignment.bottomCenter,
              child: CaptionField(context, hintstyle))
        ],
      ),
    );
  }

  Widget CaptionField(BuildContext context, TextStyle hintStyle) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SmoothPageIndicator(
            controller: pc,
            count: widget.selectedImages.length,
            axisDirection: Axis.horizontal,
            effect: WormEffect(
                spacing: 8.0,
                dotWidth: 12.0,
                dotHeight: 12.0,
                paintStyle: PaintingStyle.stroke,
                strokeWidth: 1.5,
                dotColor: Theme.of(context).colorScheme.secondary,
                activeDotColor: Theme.of(context).colorScheme.secondary),
          ),
        ),
        Container(
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
                  String caption = _tccaption.text;
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
      ],
    );
  }

  Widget MediaButton(BuildContext context, IconData icon, Color color) {
    return MaterialButton(
      onPressed: () {},
      color: Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
      padding: const EdgeInsets.all(16),
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: 15,
        color: color,
      ),
    );
  }
}
