import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatelessWidget {
  final Timestamp timestamp;
  const DateHeader({super.key, required this.timestamp});

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat dateFormat = DateFormat('MMM d, yyyy');
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
