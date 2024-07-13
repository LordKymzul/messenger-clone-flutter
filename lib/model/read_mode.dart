class ReadModel {
  final String readBy;
  final int numUnRead;

  ReadModel({required this.readBy, required this.numUnRead});

  Map<String, dynamic> toJson() => {'readBy': readBy, 'numUnRead': numUnRead};

  factory ReadModel.fromJson(Map<String, dynamic> json) {
    return ReadModel(readBy: json['readBy'], numUnRead: json['numUnRead'] ?? 0);
  }
}
