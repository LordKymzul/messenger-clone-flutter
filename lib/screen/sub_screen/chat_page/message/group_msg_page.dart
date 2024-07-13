import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/message_services.dart';
import 'package:message_app/services/read_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/provider/message_provider.dart';
import 'package:message_app/screen/widget/message_component/msg_card_comp.dart';
import 'package:message_app/screen/widget/util/iconback.dart';
import 'package:message_app/screen/widget/util/textfield/message_tf.dart';
import 'package:message_app/screen/sub_screen/chat_page/detail/group_detail_page.dart';
import 'package:provider/provider.dart';

import '../../../../services/userprofile_services.dart';
import '../../../../model/message_model.dart';
import '../../../widget/loading_component/error_comp.dart';
import '../../../widget/loading_component/load_comp.dart';
import '../../../widget/util/bottom_sheet/pick_bs.dart';
import '../../../widget/util/date/dateheader.dart';
import '../../media_page.dart';
import '../detail/photo_msg_detail.dart';

class GroupMessage extends StatefulWidget {
  final String groupURL, groupName, groupID;
  final int groupMembers;

  GroupMessage(
      {super.key,
      required this.groupURL,
      required this.groupName,
      required this.groupMembers,
      required this.groupID});

  @override
  State<GroupMessage> createState() => _GroupMessageState();
}

class _GroupMessageState extends State<GroupMessage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _tcmessage = TextEditingController();
  File? image;
  var imagepick;
  List<XFile?> imageFileList = [];
  List<dynamic> listUrlDownloads = [];
  UploadTask? uploadTask;

  Future<void> selectImages(BuildContext context) async {
    try {
      final List<XFile?> selectedImages = await ImagePicker().pickMultiImage();
      if (selectedImages.isEmpty) {
        return;
      }
      imageFileList.clear();
      imageFileList.addAll(selectedImages);
      Provider.of<MessageProvider>(context, listen: false)
          .addlistMessageURL(imageFileList);

      setState(() {});

      Navigator.pop(context);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

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

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MediaPage(
          image: image,
          imagepick: imagepicked,
          groupID: widget.groupID,
          isStatus: false,
          selectedImages: [],
          selectedImagesNames: [],
        ),
      ));
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  Future<void> uploadToFirebaseStorage(
    String messageText,
    BuildContext context,
    List<XFile?> imageFileListProvider,
  ) async {
    List<dynamic> imageName = [];
    try {
      listUrlDownloads.clear();
      imageName.clear();
      for (var eachImage in imageFileListProvider) {
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
        imageName.add(eachImage.name);
      }
      MessageServices.sendMessage(
          widget.groupID, messageText, listUrlDownloads, imageName, false);

      Provider.of<MessageProvider>(context, listen: false)
          .clearlistMessageURL();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showDialogDelete(
      BuildContext context,
      String messageID,
      String recentMessage,
      Timestamp recentTime,
      List<dynamic> messageURLName,
      String userlistId,
      String lastSender) {
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                userlistId == user.uid ? 'Delete Message' : 'Report Message',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure want to continue ?',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w300),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (userlistId == user.uid) {
                      MessageServices.deleteMessage(
                          widget.groupID,
                          messageID,
                          recentMessage,
                          recentTime,
                          messageURLName,
                          lastSender);
                    } else {
                      debugPrint('Reported');
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    ReadServices.resetUnReadMessage(widget.groupID);
    super.initState();
  }

  @override
  void dispose() {
    ReadServices.resetUnReadMessage(widget.groupID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    return Consumer<MessageProvider>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: buildAppBar(context, titlestyle, subtitlestyle),
        body: Column(
          children: [
            MessageList(),
            MessageTextField(
              tcmessage: _tcmessage,
              hintText: 'Write a message',
              hintStyle: hintstyle,
              onSend: () {
                List<XFile?> imageFileListProvider = value.listmessageURL;
                String message = _tcmessage.text.trim();
                if (imageFileListProvider.isEmpty) {
                  if (message.isEmpty) {
                    SnackBarUtil.showSnackBar(
                        'This field cannot be empty', Colors.red);
                  } else {
                    MessageServices.sendMessage(
                        widget.groupID, message, [], [], true);
                  }
                } else {
                  uploadToFirebaseStorage(
                      message, context, imageFileListProvider);
                }
                _tcmessage.clear();
              },
              onPickMedia: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          topLeft: Radius.circular(24))),
                  builder: (context) {
                    return PickButtomSheet(
                      onCamera: () {
                        pickImage(ImageSource.camera);
                      },
                      onGallery: () {
                        selectImages(context);
                      },
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(
      BuildContext context, TextStyle titlestyle, TextStyle subtitlestyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GroupDetail(
              groupURL: widget.groupURL,
              groupName: widget.groupName,
              groupID: widget.groupID,
            ),
          ));
        },
        child: Row(
          children: [
            IconBack(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: ListTile(
              leading: buildProfilePicture(widget.groupURL, 40.0),
              title: Text(
                widget.groupName,
                style: titlestyle,
              ),
              subtitle: Text(
                '${widget.groupMembers} members',
                style: subtitlestyle,
              ),
            ))
          ],
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.tertiary,
            ))
      ],
    );
  }

  Widget MessageList() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UserGroup')
            .doc(widget.groupID)
            .collection('Messages')
            .orderBy('sendAt', descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingUI());
          } else if (snapshot.hasError) {
            return Center(
                child: ErrorUI(
              error: snapshot.error.toString(),
            ));
          } else if (snapshot.hasData) {
            return GroupedListView(
              reverse: true,
              order: GroupedListOrder.DESC,
              elements: snapshot.data!.docs,
              groupBy: (element) {
                final Timestamp timestamp = element['sendAt'];
                return DateTime(timestamp.toDate().year,
                    timestamp.toDate().month, timestamp.toDate().day);
              },
              groupHeaderBuilder: (element) => Center(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.secondary),
                    child: DateHeader(
                      timestamp: element['sendAt'],
                    )),
              ),
              indexedItemBuilder: (context, element, index) {
                MessageModel messageModel = MessageModel.fromJson(
                    element.data() as Map<String, dynamic>);

                String sentBy = messageModel.sentBy;
                String messageID = messageModel.messageID;
                String messageText = messageModel.messageText;
                Timestamp sentAt = messageModel.sentAt;
                List<dynamic> messageURL = messageModel.messageURL;
                List<dynamic> messageURLName = messageModel.messageURLName;
                String sentByName = messageModel.sentByName;
                String sentByAvatar = messageModel.sentByAvatar;

                int messagesLength = snapshot.data!.docs.length;

                return MesageCard(
                  groupID: widget.groupID,
                  messageModel: messageModel,
                  onView: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PhotoMessageDetail(
                        messageURL: messageURL,
                        messageURLName: messageURLName,
                        sentByName: sentByName,
                        sentAt: sentAt,
                        groupID: widget.groupID,
                        messageID: messageID,
                      ),
                    ));
                  },
                  onDelete: () {
                    if (messagesLength == 1) {
                      showDialogDelete(
                          context,
                          messageID,
                          'Start a conversation here',
                          Timestamp.fromDate(DateTime(1970, 1, 1)),
                          messageURLName,
                          sentBy,
                          '');
                    } else {
                      String recentMessage;
                      int recentIndex;
                      String lastSender;
                      switch (index) {
                        case 0:
                          recentIndex = snapshot.data!.docs.length - 2;
                          break;
                        default:
                          recentIndex = snapshot.data!.docs.length - 1;
                      }
                      var data = snapshot.data!.docs[recentIndex].data()
                          as Map<String, dynamic>;
                      MessageModel mmodel = MessageModel.fromJson(data);

                      recentMessage = mmodel.messageText;
                      Timestamp recentTime = mmodel.sentAt;
                      lastSender = mmodel.sentBy;
                      if (index == 0) {
                        showDialogDelete(context, messageID, recentMessage,
                            recentTime, messageURLName, sentBy, lastSender);
                      } else {
                        showDialogDelete(context, messageID, recentMessage,
                            recentTime, messageURLName, sentBy, lastSender);
                      }
                    }
                  },
                );
              },
            );
          } else {
            return const Center(child: LoadingUI());
          }
        },
      ),
    );
  }

  Widget buildMessageField1(BuildContext context, TextStyle hintstyle) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(24),
                            topLeft: Radius.circular(24))),
                    builder: (context) {
                      return PickButtomSheet(
                        onCamera: () {
                          pickImage(ImageSource.camera);
                        },
                        onGallery: () {
                          selectImages(context);
                        },
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Theme.of(context).colorScheme.primary),
                  child: TextField(
                    controller: _tcmessage,
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: 'Write a message',
                        hintStyle: hintstyle,
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent))),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  String message = _tcmessage.text.trim();
                  if (message.isEmpty) {
                    SnackBarUtil.showSnackBar(
                        'This field cannot be empty', Colors.red);
                  } else {
                    MessageServices.sendMessage(
                        widget.groupID, message, [], [], true);

                    _tcmessage.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfilePicture(String userProfile, radius) {
    return SizedBox(
        height: radius,
        width: radius,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius / 2),
          child: userProfile == ''
              ? Image.asset('assets/userchat.png', fit: BoxFit.cover)
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: userProfile,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
        ));
  }
}
