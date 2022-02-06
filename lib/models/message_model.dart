class MessageModel {
  late String sender, receiver;
  late String text;
  late DateTime createdAt;

  MessageModel({
    required this.sender,
    required this.receiver,
    required this.text,
    required this.createdAt,
  });

  MessageModel.fromMap(Map<String, dynamic> messageData) {
    sender = messageData["sender"];
    receiver = messageData["receiver"];
    text = messageData["message"];

    if (messageData["createdAt"] != null) {
      createdAt = messageData["createdAt"].toDate();
    } else {
      createdAt = DateTime.now();
    }
  }
}
