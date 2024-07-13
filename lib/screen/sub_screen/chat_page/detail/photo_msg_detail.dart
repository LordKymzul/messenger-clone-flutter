import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:message_app/services/message_services.dart';
import 'package:message_app/screen/widget/util/iconback.dart';
import 'package:message_app/screen/sub_screen/chat_page/detail/allphoto_detail_page.dart';

class PhotoMessageDetail extends StatelessWidget {
  final List<dynamic> messageURL, messageURLName;
  final String sentByName;
  final Timestamp sentAt;
  final String groupID, messageID;

  PhotoMessageDetail({
    super.key,
    required this.messageURL,
    required this.messageURLName,
    required this.sentByName,
    required this.sentAt,
    required this.groupID,
    required this.messageID,
  });

  String formatHour(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat('HH:mm');
    return dateFormat.format(dateTime);
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat('MMM d, yyyy');
    return dateFormat.format(dateTime);
  }

  String eachMessageURL = '';
  String eachMessageURLName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          PageView.builder(
            itemCount: messageURL.length,
            itemBuilder: (context, index) {
              eachMessageURL = messageURL[index];
              eachMessageURLName = messageURLName[index];

              return Image.network(eachMessageURL);
            },
          )
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        children: [
          IconBack(
            onBack: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: RichText(
                  text: TextSpan(children: [
            TextSpan(
                text: '$sentByName on',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.tertiary)),
            const WidgetSpan(
              child: SizedBox(width: 5),
            ),
            TextSpan(
                text: '${formatDate(sentAt)} ,',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.tertiary)),
            const WidgetSpan(
              child: SizedBox(width: 5),
            ),
            TextSpan(
                text: formatHour(sentAt),
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.tertiary))
          ])))
        ],
      ),
      actions: [
        Center(
          child: IconButton(
              onPressed: () {
                MessageServices.deleteEachMessageURL(
                    groupID,
                    messageID,
                    eachMessageURL,
                    eachMessageURLName,
                    messageURL,
                    messageURLName);
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        )
      ],
    );
  }
}
