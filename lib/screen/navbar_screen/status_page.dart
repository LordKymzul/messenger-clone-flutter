import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/status2_services.dart';
import 'package:message_app/services/status_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/status_model.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/loading_component/error_comp.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';
import 'package:message_app/screen/widget/loading_component/statusload_comp.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/status_component/status_card_comp.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/widget/user_component/user_bubble/user_bubble_status_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:message_app/screen/widget/util/bottom_sheet/delete_bs.dart';
import 'package:message_app/screen/widget/util/date/dateheader.dart';
import 'package:message_app/screen/widget/util/date/datemessage.dart';
import 'package:message_app/screen/sub_screen/status_page/status_screen_page.dart';
import 'package:message_app/screen/sub_screen/status_page/upload_status_page.dart';

import '../../constant/snakbar.dart';
import '../widget/user_component/user_bubble/user_bubble_online_comp.dart';
import '../widget/util/bottom_sheet/pick_bs.dart';
import '../sub_screen/media_page.dart';

class StatusPage extends StatefulWidget {
  StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final _tcsearch = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  List<String> friendsID = [];
  UserModel? userModel;
  StatusModel? statusModel;
  File? image;
  var imagepick;
  String dummyurl =
      'https://variety.com/wp-content/uploads/2022/01/Screen-Shot-2022-01-19-at-6.27.33-PM.png';

  String masonary1 =
      'https://images.unsplash.com/photo-1575936123452-b67c3203c357?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D&w=1000&q=80';

  String masonary2 =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Mona_Lisa-restored.jpg/1200px-Mona_Lisa-restored.jpg';

  String username = '';
  String userID = '';

  @override
  void initState() {
    super.initState();
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
          groupID: '',
          isStatus: true,
          selectedImages: [],
          selectedImagesNames: [],
        ),
      ));
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);

    final hintstyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(context, appbarstyle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeaderStatus(),
          fetchStatusList(),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Status',
        style: appbarstyle,
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
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
          icon: Icon(
            Icons.camera_alt_outlined,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        )
      ],
    );
  }

  Widget buildHeaderStatus() {
    return SizedBox(
      height: 110,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [fetchUserProfile(), buildCustomUserStatus()],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'You Status',
                    style: GoogleFonts.poppins(fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          fetchStatusBubbles()
        ],
      ),
    );
  }

  Widget fetchStatusBubbles() {
    return FutureBuilder<List<String>>(
      future: UserProfileServices.fetchFriendIDs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> userlistId = snapshot.data!;
          debugPrint(userlistId.length.toString());
          for (var each in userlistId) {
            debugPrint(each);
          }
          if (userlistId.isEmpty) {
            return const SliverToBoxAdapter(
                child: SizedBox(
              height: 10,
              width: 10,
            ));
          } else {
            return StatusBubbles(userlistId);
          }
        } else {
          debugPrint('Error fetch status bubbles');
          return const SliverToBoxAdapter(
              child: SizedBox(
            height: 10,
            width: 10,
          ));
        }
      },
    );
  }

  Widget fetchStatusList() {
    return FutureBuilder<List<String>>(
      future: UserProfileServices.fetchFriendIDs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> userlistId = snapshot.data!;
          debugPrint(userlistId.length.toString());
          for (var each in userlistId) {
            debugPrint(each);
          }

          return StatusList(userlistId);
        } else {
          return Container();
        }
      },
    );
  }

  Widget StatusBubbles(List<String> userlistID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .where('userId', whereIn: [...userlistID])
          .orderBy('lastStatus', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: Container());
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return SliverToBoxAdapter(
              child: ErrorUI(error: snapshot.error.toString()));
        } else if (snapshot.hasData) {
          return SliverList(
              delegate: SliverChildBuilderDelegate(
                  childCount: snapshot.data!.docs.length, (context, index) {
            Map<String, dynamic> data = snapshot.data!.docs[index].data();
            UserModel userModel = UserModel.fromJson(data);
            String userID = userModel.userId;
            return UserBubbleStatus(
              userlistId: userID,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StatusScreen(userlistID: userID),
                ));
              },
            );
          }));
        } else {
          return const SliverToBoxAdapter(child: Center(child: LoadingUI()));
        }
      },
    );
  }

  Widget StatusList(List<String> userlistID) {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UserStatus')
            .where('sentBy', whereIn: [...userlistID, user.uid])
            .orderBy('sentAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Center(
                child: ErrorUI(
              error: snapshot.error.toString(),
            ));
          } else if (snapshot.hasData) {
            return MasonryGridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
              itemBuilder: (context, index) {
                var statusData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                StatusModel statusModel = StatusModel.fromJson(statusData);
                String statusURL = statusModel.statusURL;
                String statusURLName = statusModel.statusURLName;
                String sentBy = statusModel.sentBy;
                Timestamp timestamp = statusModel.sentAt;
                String statusID = statusModel.statusID;
                String statusUserName = statusModel.statusUserName;
                String statusUserAvatar = statusModel.statusUserAvatar;

                Status2Services.deleteStatus24Hours(statusID);

                return StatusCard(
                  statusURL: statusURL,
                  sentBy: sentBy,
                  timestamp: timestamp,
                  onDelete: () {
                    toggle_delete_bs(
                        statusID, sentBy, statusURLName, timestamp);
                  },
                  onTap: () {
                    Status2Services.deleteStatus24Hours(statusID);
                  },
                  statusUserName: statusUserName,
                  statusUserAvatar: statusUserAvatar,
                );
              },
            );
          } else {
            return StatusLoad();
          }
        },
      ),
    );
  }

  Widget fetchUserProfile() {
    return FutureBuilder(
      future: UserProfileServices.getUserDetail(UserProfileServices.user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel userModel = snapshot.data!;
          String userProfile = userModel.userprofile;
          return EachUserProfile(userProfile: userProfile, radius: 75);
        } else {
          return Container(
            height: 65,
            width: 65,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.amber),
          );
        }
      },
    );
  }

  void toggle_delete_bs(String statusID, String userlistId,
      String statusURLName, Timestamp lastStatus) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24), topLeft: Radius.circular(24))),
      context: context,
      builder: (context) {
        return DeleteButtomSheet(
          onTapDelete: () {
            debugPrint('DELETE');
            Status2Services.deleteStatus(statusID, statusURLName, lastStatus);
          },
          userlistId: userlistId,
        );
      },
    );
  }

  Widget buildCustomUserStatus() {
    return Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.background),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
