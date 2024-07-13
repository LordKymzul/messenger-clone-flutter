import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

class UserBubbleOnline extends StatelessWidget {
  final String userProfile, userName;
  final bool isOnline;
  const UserBubbleOnline(
      {super.key,
      required this.userProfile,
      required this.userName,
      required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final namestyle = GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              buildProfilePicture(userProfile, 70.0),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? Colors.green : Colors.grey,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.background,
                          width: 2)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              userName,
              style: namestyle,
            ),
          ),
        ],
      ),
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
