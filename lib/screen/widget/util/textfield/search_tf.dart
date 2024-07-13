import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTextField extends StatelessWidget {
  final tcsearch;
  final void Function(String)? onChanged;
  const SearchTextField(
      {super.key, required this.tcsearch, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final hintstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey);
    return buildSearchField(context, hintstyle);
  }

  Widget buildSearchField(BuildContext context, TextStyle hintStyle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primary),
        child: TextField(
          controller: tcsearch,
          obscureText: false,
          keyboardType: TextInputType.name,
          onChanged: onChanged,
          decoration: InputDecoration(
              hintText: 'Search here',
              hintStyle: hintStyle,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent))),
        ),
      ),
    );
  }
}
