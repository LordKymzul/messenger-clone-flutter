import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/message_services.dart';
import 'package:message_app/services/read_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/provider/message_provider.dart';
import 'package:message_app/screen/widget/loading_component/error_comp.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';
import 'package:message_app/screen/widget/message_component/msg_card_comp.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userbio_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:message_app/screen/widget/util/date/date.dart';
import 'package:message_app/screen/widget/util/date/dateheader.dart';
import 'package:message_app/screen/widget/util/bottom_sheet/pick_bs.dart';
import 'package:message_app/screen/sub_screen/chat_page/detail/photo_msg_detail.dart';
import 'package:message_app/screen/sub_screen/chat_page/detail/private_chat_detail_page.dart';
import 'package:message_app/screen/sub_screen/media_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widget/util/textfield/message_tf.dart';

class MessagePage extends StatefulWidget {
  final String userlistid;
  final String groupID;

  MessagePage({
    super.key,
    required this.userlistid,
    required this.groupID,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _tcmessage = TextEditingController();
  final _tcsearch = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  bool isOpen = false;
  final user = FirebaseAuth.instance.currentUser!;
  String searchChat = '';
  File? image;
  var imagepick;
  bool isSearch = false;
  UserModel? userModel;
  List<XFile?> imageFileList = [];
  List<dynamic> imageFileName = [];
  //=========User Detail============//
  int numberPhone = 0;
  List<int> scrollIndex = [];
  int _counter = 0;
  UploadTask? uploadTask;
  List<dynamic> listUrlDownloads = [];

  @override
  void initState() {
    fetchUserDetail();
    ReadServices.resetUnReadMessage(widget.groupID);
    super.initState();

    /* KeyboardVisibilityController().onChange.listen((isVisible) {
      final message = isVisible ? 'Keyboard open' : 'Keyboard Hidden';
      print(message);

      setState(() {
        isOpen = isVisible;
      });
    });*/
  }

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
          selectedImages: imageFileList,
          selectedImagesNames: imageFileName,
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

  Future<void> fetchUserDetail() async {
    try {
      userModel = await UserProfileServices.getUserDetail(widget.userlistid);
      setState(() {
        numberPhone = userModel!.usernumber;
      });
      debugPrint(numberPhone.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    ReadServices.resetUnReadMessage(widget.groupID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentstyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final cancelstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.secondary);
    return Consumer<MessageProvider>(
      builder: (context, value, child) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: buildAppBar(context, contentstyle, hintstyle, cancelstyle),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              MessageList(),
              MessageTextField(
                tcmessage: _tcmessage,
                hintText: 'Write a message',
                hintStyle: hintstyle,
                onSend: () {
                  String message = _tcmessage.text.trim();
                  if (imageFileList.isEmpty) {
                    if (message.isEmpty) {
                      SnackBarUtil.showSnackBar(
                          'This field cannot be empty', Colors.red);
                    } else {
                      MessageServices.sendMessage(
                          widget.groupID, message, [], [], true);
                    }
                  } else {
                    List<XFile?> imageFileListProvider = value.listmessageURL;
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
          )),
    );
  }

  AppBar buildAppBar(BuildContext context, TextStyle contentstyle,
      TextStyle hintStyle, TextStyle cancelstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: isSearch ? SearchAppBar(hintStyle) : UserAppBar(contentstyle),
      actions: isSearch ? notSearch() : Search(),
    );
  }

  List<Widget> notSearch() {
    return [
      IconButton(
          onPressed: () {
            // Function to scroll to a specific index in the list
            /*    void scrollToIndex(int index) async {
              await Future.delayed(
                  const Duration(seconds: 1)); // Add a delay between scrolls
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  index * 50.0, // Adjust the scroll position as needed
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              }
            }

            // Scroll to each index in the scrollToIndexes list
            for (int index in scrollIndex) {
              scrollToIndex(index);
              debugPrint('Go to index: ${index.toString()}');
            }*/

            scrollController.animateTo(
              1 * 50.0, // Adjust the scroll position as needed
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
            setState(() {
              _counter++;
            });

            debugPrint(_counter.toString());
          },
          icon: Icon(
            Icons.arrow_upward,
            color: Theme.of(context).colorScheme.secondary,
          )),
      IconButton(
          onPressed: () {
            debugPrint('Downward');
          },
          icon: Icon(
            Icons.arrow_downward,
            color: Theme.of(context).colorScheme.secondary,
          )),
    ];
  }

  List<Widget> Search() {
    return [
      IconButton(
          onPressed: () {
            setState(() {
              isSearch = !isSearch;
            });
            if (isSearch) {
              focusNode.requestFocus();
            }
          },
          icon: Icon(isSearch ? Icons.clear : Icons.search),
          color: Theme.of(context).colorScheme.tertiary),
      IconButton(
          onPressed: () async {
            String path = '0 ${numberPhone.toString()}';
            //final Uri _url = Uri.parse('https://flutter.dev');
            final Uri urlCall = Uri(scheme: 'tel', path: path);

            if (await canLaunchUrl(urlCall)) {
              await launchUrl(urlCall);
            } else {
              debugPrint('Cannot make the call');
            }

            debugPrint('Number Phone: $numberPhone');
            // scrollController.animateTo(2 * 50.0,
            //     duration: Duration(seconds: 1), curve: Curves.easeInOut);
          },
          icon: Icon(
            Icons.call_outlined,
            color: Theme.of(context).colorScheme.tertiary,
          ))
    ];
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
              controller: scrollController,
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
                            recentTime, messageURLName, lastSender);
                      } else {
                        showDialogDelete(context, messageID, recentMessage,
                            recentTime, messageURLName, lastSender);
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

  Widget buildMessageField(BuildContext context, TextStyle hintstyle) {
    return Column(
      children: [
        const Divider(
          color: Colors.grey,
          thickness: 1.5,
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 20, top: 10),
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

  Widget UserAppBar(TextStyle contentstyle) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PrivateChatDetail(
            userlistID: widget.userlistid,
            groupID: widget.groupID,
          ),
        ));
      },
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          Expanded(
            child: ListTile(
                leading: UserListProfile(
                  userId: widget.userlistid,
                  radius: 40,
                ),
                title: UserListName(
                  userId: widget.userlistid,
                  fontsize: 15,
                ),
                subtitle: isOnlineStatus(contentstyle)),
          ),
        ],
      ),
    );
  }

  Widget SearchAppBar(TextStyle hintStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            color: Theme.of(context).colorScheme.primary),
        child: TextField(
          controller: _tcsearch,
          obscureText: false,
          keyboardType: TextInputType.name,
          focusNode: focusNode,
          onChanged: (value) async {
            setState(() {
              searchChat = value;
            });
            scrollIndex = await MessageServices.searchMessage(
                widget.groupID, _tcsearch.text);
            /* int index = await MessageServices.searchMessage(
                widget.groupID, _tcsearch.text);*/
            /* scrollController.animateTo(index * 50.0,
                duration: const Duration(seconds: 1), curve: Curves.easeInOut);*/
          },
          decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: hintStyle,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isSearch = !isSearch;
                    });
                    _tcsearch.clear();
                  },
                  icon: Icon(Icons.clear)),
              border: InputBorder.none),
        ),
      ),
    );
  }

  Widget isOnlineStatus(TextStyle contentstyle) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(widget.userlistid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            UserModel userModel = UserModel.fromJson(data);
            bool isOnline = userModel.isOnline;
            return Text(
              isOnline ? 'Online' : 'Offline',
              style: contentstyle,
            );
          } else {
            return Text(
              'Online',
              style: contentstyle,
            );
          }
        } else {
          return Text(
            'Online',
            style: contentstyle,
          );
        }
      },
    );
  }

  void showDialogDelete(
      BuildContext context,
      String messageID,
      String recentMessage,
      Timestamp recentTime,
      List<dynamic> messageURLName,
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
                'Delete Message',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure want to delete this message?',
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
                    MessageServices.deleteMessage(widget.groupID, messageID,
                        recentMessage, recentTime, messageURLName, lastSender);
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
}
