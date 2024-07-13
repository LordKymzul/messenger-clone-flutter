import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String statusID;
  final String statusURL;
  final String statusURLName;
  final String statusCaption;
  final String sentBy;
  final Timestamp sentAt;
  final String statusUserName;
  final String statusUserAvatar;

  StatusModel(
      {required this.statusID,
      required this.statusURL,
      required this.statusURLName,
      required this.statusCaption,
      required this.sentBy,
      required this.sentAt,
      required this.statusUserName,
      required this.statusUserAvatar});

  Map<String, dynamic> createMyMap() {
    return {
      'statusID': statusID,
      'statusURL': statusURL,
      'statusURLName': statusURLName,
      'statusCaption': statusCaption,
      'sentBy': sentBy,
      'sentAt': sentAt,
    };
  }

  Map<String, dynamic> toJson() => {
        'statusID': statusID,
        'statusURL': statusURL,
        'statusURLName': statusURLName,
        'statusCaption': statusCaption,
        'sentBy': sentBy,
        'sentAt': sentAt,
        'statusUserName': statusUserName,
        'statusUserAvatar': statusUserAvatar
      };

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
        statusID: json['statusID'],
        statusURL: json['statusURL'],
        statusURLName: json['statusURLName'],
        statusCaption: json['statusCaption'],
        sentBy: json['sentBy'],
        sentAt: json['sentAt'],
        statusUserName: json['statusUserName'],
        statusUserAvatar: json['statusUserAvatar']);
  }
}
