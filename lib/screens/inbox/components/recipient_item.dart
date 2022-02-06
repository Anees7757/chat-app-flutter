import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';

class RecipientItem extends StatelessWidget {
  final Function onTap;
  final UserModel user;
  final MessageModel? message;

  RecipientItem({required this.onTap, required this.user, this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              onTap();
            },
            leading: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent,
                    radius: 25,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
            title: Text(user.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                          message != null ? message!.text : "Start a conversation",
                          style: TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                        message == null ?
                        "${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}"
                        : "Just Now"),
          ),
          Divider(thickness: 1, height: 0),
        ],
      ),
    );
  }
}
