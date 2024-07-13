import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MessageModel {
  final String messageID;
  final String messageText;
  final List<dynamic> messageURL;
  final List<dynamic> messageURLName;
  final String sentBy;
  final Timestamp sentAt;
  final bool isText;
  final String sentByName;
  final String sentByAvatar;

  MessageModel(
      {required this.messageID,
      required this.messageText,
      required this.messageURL,
      required this.messageURLName,
      required this.sentBy,
      required this.sentAt,
      required this.isText,
      required this.sentByName,
      required this.sentByAvatar});

  Map<String, dynamic> toJson() => {
        'messageID': messageID,
        'messageText': messageText,
        'messageURL': messageURL,
        'messageURLName': messageURLName,
        'sentBy': sentBy,
        'sendAt': sentAt,
        'isText': isText,
        'sentByName': sentByName,
        'sentByAvatar': sentByAvatar
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        messageID: json['messageID'] ?? '',
        messageText: json['messageText'] ?? '',
        messageURL: List<dynamic>.from(json['messageURL'] ?? []),
        messageURLName: List<dynamic>.from(json['messageURLName'] ?? []),
        sentBy: json['sentBy'] ?? '',
        sentAt: json['sendAt'],
        isText: json['isText'] ?? '',
        sentByName: json['sentByName'] ?? '',
        sentByAvatar: json['sentByAvatar'] ?? '');
  }
}
