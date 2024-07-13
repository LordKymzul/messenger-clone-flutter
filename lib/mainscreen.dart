import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/screen/navbar_screen/member_page.dart';
import 'package:message_app/screen/navbar_screen/chat_page.dart';

import 'package:message_app/screen/navbar_screen/profile_page.dart';
import 'package:message_app/screen/navbar_screen/status_page.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedindex = 0;

  List<Widget> _pages = [ChatPage(), StatusPage(), MemberPage(), ProfilePage()];

  void selectedIndex(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    UserProfileServices.updateUserOnlineStatus(true);

    SystemChannels.lifecycle.setMessageHandler(
      (message) {
        debugPrint('Message: $message');

        if (message.toString().contains('resume')) {
          UserProfileServices.updateUserOnlineStatus(true);
          debugPrint('User Online');
        }

        if (message.toString().contains('pause')) {
          UserProfileServices.updateUserOnlineStatus(false);

          debugPrint('User Offline');
        }

        return Future.value(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.transparent,
            gap: 8,
            activeColor: Theme.of(context).colorScheme.secondary,
            color: Colors.grey,
            tabBackgroundColor: Colors.grey[200]!,
            onTabChange: (value) {
              selectedIndex(value);
            },
            tabs: const [
              GButton(
                icon: Icons.chat,
                text: 'Chat',
              ),
              GButton(
                icon: Icons.stacked_bar_chart,
                text: 'Status',
              ),
              GButton(
                icon: Icons.people,
                text: 'Friends',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedindex],
    );
  }
}
