import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/screen/widget/loading_component/error_comp.dart';
import 'package:message_app/screen/widget/loading_component/load_comp.dart';

class AllPhotoDetail extends StatelessWidget {
  final List<dynamic> allmessageURL;
  const AllPhotoDetail({super.key, required this.allmessageURL});

  @override
  Widget build(BuildContext context) {
    final appbarstyle = GoogleFonts.poppins(
        fontSize: 18,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: buildAppBar(context, appbarstyle),
        body: buildPhotoList());
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
        'Photos',
        style: appbarstyle,
      ),
    );
  }

  Widget buildPhotoList() {
    return GridView.builder(
      itemCount: allmessageURL.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
      itemBuilder: (context, index) {
        var photo = allmessageURL[index];
        return buildPhoto(photo);
      },
    );
  }

  Widget buildPhoto(String photo) {
    return ClipRRect(
      child: photo == ''
          ? Image.asset('assets/userchat.png', fit: BoxFit.cover)
          : CachedNetworkImage(
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              imageUrl: photo,
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
    );
  }

  Widget photoLoad() {
    return const Center(child: LoadingUI());
  }
}
