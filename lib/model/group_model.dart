import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupID;
  final String createdBy;
  final Timestamp createdAt;
  final String lastMessage;
  final Timestamp lastTime;
  List<String> membersID;
  final String groupName;
  final String lastSender;
  final bool isGroup;
  final String groupURL;

  GroupModel({
    required this.groupID,
    required this.createdBy,
    required this.createdAt,
    required this.lastMessage,
    required this.lastTime,
    required this.membersID,
    required this.groupName,
    required this.lastSender,
    required this.isGroup,
    required this.groupURL,
  });

  Map<String, dynamic> toJson() => {
        'groupID': groupID,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'lastMessage': lastMessage,
        'lastTime': lastTime,
        'membersID': membersID,
        'groupName': groupName,
        'lastSender': lastSender,
        'isGroup': isGroup,
        'groupURL': groupURL,
      };

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupID: json['groupID'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'],
      lastMessage: json['lastMessage'],
      lastTime: json['lastTime'],
      membersID: List<String>.from(json['membersID'] ?? []),
      groupName: json['groupName'],
      lastSender: json['lastSender'],
      isGroup: json['isGroup'],
      groupURL: json['groupURL'],
    );
  }
}
