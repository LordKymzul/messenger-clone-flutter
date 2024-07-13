import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EachUserProfile extends StatelessWidget {
  final String userProfile;
  final double radius;
  const EachUserProfile(
      {super.key, required this.userProfile, required this.radius});

  @override
  Widget build(BuildContext context) {
    return buildProfilePicture(userProfile, radius);
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
