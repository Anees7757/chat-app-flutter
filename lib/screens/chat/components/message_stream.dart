import 'dart:async';

import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/screens/chat/components/message_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageStream extends StatefulWidget {
  final String? room;
  const MessageStream({Key? key, required this.room}) : super(key: key);

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  final _firestore = FirebaseFirestore.instance;
  
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('rooms')
          .doc(widget.room)
          .collection('chats')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs.reversed;

        List<MessageBox> messageBoxes = [];
        for (var message in messages!) {
          final msg = message.data() as Map<String, dynamic>;
          final sender = msg['sender'];
          final text = msg['message'];

          print(msg['sender']);

          final messageBox = MessageBox(
            sender: sender,
            text: text,
            isMe: currentUser == sender,
          );
          messageBoxes.add(messageBox);
        }
        return ListView(
          physics: BouncingScrollPhysics(),
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageBoxes,
        );
      },
    );
  }
}
