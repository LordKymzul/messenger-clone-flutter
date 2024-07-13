import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/provider/message_provider.dart';
import 'package:provider/provider.dart';

class MessageTextField extends StatelessWidget {
  final TextEditingController tcmessage;
  final String hintText;
  final TextStyle hintStyle;
  final void Function() onSend;
  final void Function() onPickMedia;

  const MessageTextField({
    super.key,
    required this.tcmessage,
    required this.hintText,
    required this.hintStyle,
    required this.onSend,
    required this.onPickMedia,
  });

  void remove(BuildContext context, int index) {
    Provider.of<MessageProvider>(context, listen: false)
        .removelistMessageURL(index);
  }

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<MessageProvider>(context);
    List<XFile?> imageList = value.listmessageURL;
    return Consumer(
        builder: (context, value, child) => Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
            child: isMedia(context, imageList)));
  }

  Widget isMedia(BuildContext context, List<XFile?> imageList) {
    if (imageList.isEmpty) {
      return buildMessageField(context);
    } else {
      return buildMessageWithMediaField(context, imageList);
    }
  }

  Widget buildMessageField(BuildContext context) {
    return Row(
      children: [
        buildMediaButton(context),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(32)),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: tcmessage,
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: hintStyle,
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.transparent,
                      ))),
                )),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMessageWithMediaField(
      BuildContext context, List<XFile?> imageList) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                var eachElemet = imageList[index];
                var imageURL = eachElemet!.path;
                return buildSelectedImage(imageURL, index, context);
              },
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4, right: 12, left: 12),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: tcmessage,
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: hintStyle,
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.transparent,
                      ))),
                )),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedImage(var imageURL, int index, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8, right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.file(
                File(imageURL),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    remove(context, index);
                  },
                  child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
                      child: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildMediaButton(BuildContext context) {
    return GestureDetector(
      onTap: onPickMedia,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
