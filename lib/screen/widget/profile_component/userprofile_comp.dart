import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UserProfile')
            .doc(user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingURL(context);
          } else if (snapshot.hasError) {
            return loadingURL(context);
          } else if (snapshot.hasData) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                print('e');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: Image.network(
                        data['userprofile'],
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
            );
          } else {
            return loadingURL(context);
          }
        });
  }

  Widget loadingURL(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary),
    );
  }
}
