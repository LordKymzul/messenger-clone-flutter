import 'package:flutter/material.dart';

class IconBack extends StatelessWidget {
  final void Function() onBack;
  const IconBack({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Icon(
        Icons.arrow_back_ios_new,
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
