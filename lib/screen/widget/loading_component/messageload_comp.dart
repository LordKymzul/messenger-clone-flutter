import 'package:flutter/material.dart';
import 'package:message_app/constant/CustomColors.dart';

class MessageLoad extends StatelessWidget {
  const MessageLoad({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: CustomColors.loadColors),
      ),
      title: Container(
        height: 10,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: CustomColors.loadColors),
      ),
      subtitle: Container(
        height: 10,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: CustomColors.loadColors),
      ),
    );
  }
}
