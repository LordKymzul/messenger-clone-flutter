import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListProfile extends StatelessWidget {
  final String userId;
  final double radius;

  const UserListProfile(
      {super.key, required this.userId, required this.radius});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return loadingURL();
        } else if (snapshot.hasData) {
          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          String profileURL =
              userData['userprofile'] ?? ''; // Access the 'userprofile' field
          return buildProfilePicture(profileURL, radius);
        } else {
          return loadingURL();
        }
      },
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

  Widget loadingURL() {
    return Container(
      height: 50,
      width: 50,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
    );
  }
}
