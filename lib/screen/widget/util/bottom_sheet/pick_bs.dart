import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PickButtomSheet extends StatelessWidget {
  void Function() onCamera;
  void Function() onGallery;
  PickButtomSheet({super.key, required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    final titlestyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    Color color = Theme.of(context).colorScheme.tertiary;
    return SizedBox(
        height: 150,
        child: Column(
          children: [
            ListTile(
                leading: Icon(
                  Icons.camera,
                  color: color,
                ),
                title: Text(
                  'Pick From Camera',
                  style: titlestyle,
                ),
                onTap: onCamera),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            ListTile(
                leading: Icon(
                  Icons.image,
                  color: color,
                ),
                title: Text('Pick From Gallery', style: titlestyle),
                onTap: onGallery),
          ],
        ));
  }
}
