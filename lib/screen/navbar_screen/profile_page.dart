import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_username.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';

import 'package:message_app/screen/sub_screen/setupprofile_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/userprofile_services.dart';
import '../../auth/intro_page.dart';
import '../../constant/snakbar.dart';
import '../../model/user_model.dart';
import '../widget/profile_component/profilemenu_comp.dart';

import '../sub_screen/setting_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String username = '';
  String userprofile = '';
  String userbio = '';
  int usernumber = 0;
  String useremail = '';
  UserModel? userModel;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    try {
      userModel = await UserProfileServices.getUserDetail(user.uid);
      setState(() {
        username = userModel!.username;
        userprofile = userModel!.userprofile;
        userbio = userModel!.userbio;
        usernumber = userModel!.usernumber;
        useremail = userModel!.useremail;
      });
      debugPrint(userprofile);
    } catch (e) {
      debugPrint('Cannot fetch user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final idstyle = GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final titlestyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey);
    final contentstyle = GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final bottomstyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: buildAppBar(appbarstyle),
        body: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              buildContent(idstyle, titlestyle, subtitlestyle, contentstyle)
            ])),
            buildListGroups(contentstyle),
            const SliverToBoxAdapter(
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            buildBottom(bottomstyle)
          ],
        ));
  }

  AppBar buildAppBar(TextStyle appbarstyle) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Profile',
        style: appbarstyle,
      ),
      leading: Icon(
        Icons.abc,
        color: Theme.of(context).colorScheme.background,
      ),
    );
  }

  Widget buildContent(TextStyle idstyle, TextStyle titlestyle,
      TextStyle subtitlestyle, TextStyle contentstyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(idstyle),
        const Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        buildBio(titlestyle, contentstyle),
        const Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        buildInformation(titlestyle, subtitlestyle),
        const Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Groups',
                style: titlestyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildHeader(TextStyle idstyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EachUserProfile(userProfile: userprofile, radius: 100),
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EachUserName(
                    userName: username,
                    fontSize: 18,
                  ),
                  Text(
                    user.uid.toString(),
                    style: idstyle,
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SetupProfilePage(
                      username: username,
                      userprofile: userprofile,
                      userbio: userbio,
                      usernumber: usernumber),
                ));
              },
              child: Center(
                  child: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              )),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBio(TextStyle titlestyle, TextStyle contentstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: titlestyle,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            userbio,
            style: contentstyle,
          )
        ],
      ),
    );
  }

  Widget buildInformation(TextStyle titlestyle, TextStyle subtitlestyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: titlestyle,
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: subtitlestyle,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(useremail),
                  Icon(
                    Icons.email,
                    color: Theme.of(context).colorScheme.tertiary,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Phone Number',
                style: subtitlestyle,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0${usernumber.toString()}'),
                  Icon(
                    Icons.phone,
                    color: Theme.of(context).colorScheme.tertiary,
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildListGroups(TextStyle contentstyle) {
    return FutureBuilder<List<GroupModel>>(
      future: UserProfileServices.fetchUserGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: Container());
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return SliverToBoxAdapter(child: Container());
        } else if (snapshot.hasData) {
          List<GroupModel> groups = snapshot.data!;
          if (groups.isEmpty) {
            return SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your groups list is empty.',
                style: contentstyle,
              ),
            ));
          } else {
            return SliverList(
                delegate: SliverChildBuilderDelegate(childCount: groups.length,
                    (context, index) {
              var eachElement = groups[index];
              String groupProfile = eachElement.groupURL;
              String groupName = eachElement.groupName;
              String groupAdmin = eachElement.createdBy;
              return ListTile(
                leading: buildGroupProfile(groupProfile),
                title: Text(
                  groupName,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      'Created By',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    UserListName(userId: groupAdmin, fontsize: 12)
                  ],
                ),
              );
            }));
          }
        } else {
          return SliverToBoxAdapter(child: Container());
        }
      },
    );
  }

  Widget buildBottom(TextStyle bottomstyle) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildSignOutButton(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Developed By Hakim',
              style: bottomstyle,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(
                        'https://www.linkedin.com/in/qem-undefined-523748272/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      debugPrint('Cannot lauch URL');
                    }
                  },
                  icon: Image.asset('assets/facebook.png')),
              IconButton(
                  onPressed: () async {
                    final Uri url =
                        Uri.parse('https://www.instagram.com/kem.zul/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      debugPrint('Cannot lauch URL');
                    }
                  },
                  icon: Image.asset('assets/instagram1.png')),
              IconButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(
                        'https://www.linkedin.com/in/qem-undefined-523748272/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      debugPrint('Cannot lauch URL');
                    }
                  },
                  icon: Image.asset('assets/linkedin.png'))
            ],
          )
        ],
      ),
    );
  }

  Widget buildGroupProfile(String groupURL) {
    return SizedBox(
        height: 50,
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50 / 2),
          child: groupURL == ''
              ? Image.asset('assets/userchat.png', fit: BoxFit.cover)
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: groupURL,
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

  Widget buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        onPressed: () async {
          try {
            final firebaseAuth = FirebaseAuth.instance;
            await firebaseAuth.signOut().then((value) => Navigator.of(context)
                .pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => IntroPage()),
                    (route) => false));
          } on FirebaseAuthException catch (e) {
            debugPrint(e.toString());
          }
        },
        child: Center(
          child: Text(
            'Sign Out',
            style: GoogleFonts.poppins(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget ProfileMenuList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ProfileMenu(
            title: 'Account',
            icon: Icons.person_outline,
            press: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SetupProfilePage(
                      username: username,
                      userprofile: userprofile,
                      userbio: userbio,
                      usernumber: usernumber)));
            },
          ),
          ProfileMenu(
            title: 'Settings',
            icon: Icons.settings_outlined,
            press: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingPage(),
              ));
            },
          ),
          ProfileMenu(
            title: 'Help Center',
            icon: Icons.help_center_outlined,
            press: () {},
          ),
          ProfileMenu(
            title: 'Logout',
            icon: Icons.logout,
            press: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => IntroPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
