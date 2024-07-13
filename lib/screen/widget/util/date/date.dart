import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Date extends StatelessWidget {
  final Timestamp timestamp;
  const Date({super.key, required this.timestamp});

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat('dd MMM yy HH:mm');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final datestyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    return Text(
      formatDate(timestamp),
      style: datestyle,
    );
  }
}
