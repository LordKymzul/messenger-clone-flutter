import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/mainscreen.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/buttons_component/requestbtn_comp.dart';
import 'package:message_app/screen/widget/loading_component/error_comp.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userbio.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_username.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/widget/user_component/user_util/userbio_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/usersearch_comp.dart';
import 'package:message_app/screen/sub_screen/chat_page/create/add_member_group_page.dart';
import 'package:message_app/screen/sub_screen/chat_page/detail/allphoto_detail_page.dart';

import '../../../../constant/snakbar.dart';
import '../../../widget/util/bottom_sheet/pick_bs.dart';

class GroupDetail extends StatefulWidget {
  final String groupURL, groupName, groupID;
  const GroupDetail(
      {super.key,
      required this.groupURL,
      required this.groupName,
      required this.groupID});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  bool isSelected = false;
  bool isLoading = false;
  File? image;
  final _tcgroupname = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  var imagepick;
  UploadTask? uploadTask;
  List<dynamic> membersLength = [];
  List<dynamic> allmessageURL = [];
  String admin = '';
  GroupModel? groupModel;

  @override
  void initState() {
    _tcgroupname.text = widget.groupName;
    getGroupDetail();
    super.initState();
  }

  bool isUser(String userlistID) {
    if (user.uid == userlistID) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getGroupDetail() async {
    try {
      groupModel = await ChatServices.fetchGroupDetail(widget.groupID);
      setState(() {
        admin = groupModel!.createdBy;
      });
      debugPrint('Group Admin: $admin');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> pickImage(ImageSource source) async {
    setState(() {
      isSelected = true;
    });
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

  Future<void> updateGroupURL(String groupName) async {
    GroupModel? groupModel;

    setState(() {
      isLoading = true;
    });
    try {
      groupModel = await ChatServices.fetchGroupDetail(widget.groupID);
      String groupID = groupModel!.groupID;
      final file = File(imagepick!.path!);
      final ref =
          FirebaseStorage.instance.ref().child('GroupURL').child(groupID);

      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(widget.groupID);
      documentReference.update({'groupURL': urlDownload});

      Navigator.pop(context);
    } catch (e) {
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
      debugPrint(e.toString());
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
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final headerstyle = GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.w600);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.w600);
    final contentstyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: buildAppBar(context, appbarstyle),
        body: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  groupProfile(headerstyle, contentstyle),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  groupName(titlestyle),
                  const SizedBox(
                    height: 10,
                  ),
                  groupMedia(titlestyle, subtitlestyle),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members',
                          style: titlestyle,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddGroupMember(
                                membersID: membersLength,
                                groupID: widget.groupID,
                              ),
                            ));
                          },
                          child: Text(
                            'Add People',
                            style: subtitlestyle,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ])),
            buildMembersList(),
            buildLeaveButton(),
            if (admin == user.uid) buildDeleteButton()
          ],
        ));
  }

  AppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios_new,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      centerTitle: true,
      title: Text(
        'Details',
        style: appbarstyle,
      ),
      actions: [
        IconButton(
            onPressed: () {
              updateGroupURL(widget.groupName);
            },
            icon: Icon(
              Icons.done,
              color: Theme.of(context).colorScheme.tertiary,
            ))
      ],
    );
  }

  Widget groupProfile(TextStyle headerstyle, TextStyle contentstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
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
                        pickImage(ImageSource.gallery);
                      },
                    );
                  },
                );
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
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(64),
                          child: Image.network(
                            widget.groupURL,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
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
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Change Group Photo',
              style: headerstyle,
            ),
            const SizedBox(
              height: 10,
            ),
            groupAdmin(contentstyle)
          ],
        ),
      ),
    );
  }

  Widget groupName(TextStyle titlestyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Name',
            style: titlestyle,
          ),
          TextField(
            controller: _tcgroupname,
            obscureText: false,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          )
        ],
      ),
    );
  }

  Widget groupAdmin(TextStyle contentstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Group Admin',
            style: contentstyle,
          ),
          const SizedBox(
            width: 5,
          ),
          FutureBuilder(
            future: ChatServices.fetchGroupDetail(widget.groupID),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                GroupModel groupModel = snapshot.data!;
                return UserListName(userId: groupModel.createdBy, fontsize: 15);
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }

  Widget groupMedia(TextStyle titlestyle, TextStyle subtitlestyle) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photos',
                style: titlestyle,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AllPhotoDetail(
                      allmessageURL: allmessageURL,
                    ),
                  ));
                },
                child: Text(
                  'See All',
                  style: subtitlestyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('UserGroup')
              .doc(widget.groupID)
              .collection('Messages')
              .where('isText', isEqualTo: false)
              .orderBy('sendAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return photoLoad();
            } else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return ErrorUI(error: snapshot.error.toString());
            } else if (snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return SizedBox(
                    height: 50,
                    child: Center(
                        child: Text(
                      'No Photo yet',
                      style: titlestyle,
                    )));
              } else {
                for (var eachDoc in snapshot.data!.docs) {
                  MessageModel messageModel = MessageModel.fromJson(
                      eachDoc.data() as Map<String, dynamic>);
                  List<dynamic> messageURL = messageModel.messageURL;
                  for (var eachURL in messageURL) {
                    allmessageURL.add(eachURL);
                  }
                }
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allmessageURL.length,
                    itemBuilder: (context, index) {
                      var image = allmessageURL[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            } else {
              return photoLoad();
            }
          },
        )
      ],
    );
  }

  Widget buildMembersList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(widget.groupID)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: LoadingUI()),
          );
        } else if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(child: LoadingUI()),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!.exists) {
            membersLength.clear();
            var data = snapshot.data!.data() as Map<String, dynamic>;

            GroupModel groupModel = GroupModel.fromJson(data);
            String groupAdmin = groupModel.createdBy;

            if (data.containsKey('membersID')) {
              List<dynamic> membersID = data['membersID'];
              membersLength.addAll(membersID);
            }
            return SliverList(
                delegate: SliverChildBuilderDelegate(
                    childCount: membersLength.length, (context, index) {
              var eachElement = membersLength[index];
              String userlistID = eachElement.toString();
              return buildMembersCard(widget.groupID, userlistID, groupAdmin);
            }));
          } else {
            return SliverToBoxAdapter(child: Container());
          }
        } else {
          return const SliverToBoxAdapter(
            child: Center(child: LoadingUI()),
          );
        }
      },
    );
  }

  Widget buildMembersCard(
      String groupID, String userlistID, String groupAdmin) {
    return Slidable(
        startActionPane: ActionPane(motion: const DrawerMotion(), children: [
          SlidableAction(
              onPressed: (context) {
                user.uid == groupAdmin
                    ? isUser(userlistID)
                        ? SnackBarUtil.showSnackBar(
                            'You are Group Admin', Colors.red)
                        : showDialogDelete(context, groupID, userlistID)
                    : debugPrint('Report');
              },
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
              backgroundColor:
                  user.uid == groupAdmin ? Colors.red : Colors.blue,
              icon: user.uid == groupAdmin ? Icons.delete : Icons.report)
        ]),
        child: ListTile(
            leading: UserListProfile(userId: userlistID, radius: 50),
            title: UserListName(userId: userlistID, fontsize: 15),
            subtitle: UserListBio(userId: userlistID),
            trailing: isUser(userlistID)
                ? const SizedBox(
                    height: 10,
                  )
                : RequestButton(
                    userlistId: userlistID,
                    press: () {},
                  )));
  }

  Widget buildLeaveButton() {
    return SliverToBoxAdapter(
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            thickness: 1.0,
            color: Colors.grey,
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 16, left: 16, bottom: 20, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialogLeaveGroup(context, widget.groupID);
                  },
                  child: Text(
                    'Leave Group',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.red,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'You wont receive messages from this group unless someone adds you to the conversation again.',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }

  Widget buildDeleteButton() {
    return SliverToBoxAdapter(
        child: Column(
      children: [
        const Divider(
          thickness: 1.0,
          color: Colors.grey,
        ),
        Padding(
          padding:
              const EdgeInsets.only(right: 16, left: 16, bottom: 20, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showDialogDeleteGroup(context, widget.groupID, membersLength);
                },
                child: Text(
                  'Delete Group',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Once you delete the group, all shared files and chat history associated with it will be irrecoverably lost.',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        )
      ],
    ));
  }

  Widget photoLoad() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: Colors.grey),
              ));
        },
      ),
    );
  }

  void showDialogDelete(
      BuildContext context, String groupID, String userlistId) {
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
                'Remove Member',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure want to remove ?',
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
                    ChatServices.removeMembersFromGroup(groupID, userlistId);
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

  void showDialogDeleteGroup(
      BuildContext context, String groupID, List<dynamic> membersID) {
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
                'Delete Group',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure want to delete this group?',
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
                    ChatServices.removeGroup(groupID, membersID);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ));
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

  void showDialogLeaveGroup(BuildContext context, String groupID) {
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
                'Leave Group',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure want to leave this group?',
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
                    ChatServices.leaveGroup(groupID);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ));
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
