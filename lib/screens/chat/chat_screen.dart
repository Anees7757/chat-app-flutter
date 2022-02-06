// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/screens/chat/components/message_stream.dart';
import 'package:chat_app/screens/inbox/inbox_screen.dart';
import 'package:chat_app/widgets/my_text_field.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String? room;
  final Map<String, dynamic> otherUser;
  const ChatScreen({
    Key? key,
    this.room,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? roomId;
  List<MessageModel> messages = [];
  StreamSubscription<dynamic>? messageSubscription;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.room != null) {
      setState(() {
        roomId = widget.room;
      });
      fetchData();
    }
  }

  void fetchData() {
    Stream collectionStream = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection("chats")
        .orderBy("createdAt", descending: false)
        .snapshots();

    if (messageSubscription != null) {
      messageSubscription!.cancel();
    }

    messageSubscription = collectionStream.listen((event) async {
      List<MessageModel> newMessages = [];

      event.docs.forEach((doc) {
        newMessages.add(MessageModel.fromMap(doc.data()));
      });

      setState(() {
        messages = newMessages;
      });

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  final _messageController = TextEditingController();

  //   void _onTapSend(TextEditingController controller, String sender) {
  //   FirebaseFirestore.instance.collection('rooms').doc(roomId)
  //       .collection("chats").add({
  //     'sender': sender,
  //     'text': controller.text.trim(),
  //     'dateTime': DateTime.now(),
  //   });
  //   controller.clear();
  // }

  @override
  Widget build(BuildContext context) {
    final UserModel otherUser = UserModel.fromMap(widget.otherUser);

    Future<String> createRoom() async {
      try {
        if (roomId != null) {
          return Future.value(roomId);
        }

        final UserModel currentUser =
            Provider.of<UserProvider>(context, listen: false).user as UserModel;

        CollectionReference room =
            FirebaseFirestore.instance.collection('rooms');

        DocumentReference doc = await room.add({
          "users": {currentUser.id: true, otherUser.id: true},
          "createdAt": FieldValue.serverTimestamp(),
        });
        await doc.set({"id": doc.id}, SetOptions(merge: true));
        setState(() {
          roomId = doc.id;
        });
        fetchData();

        return doc.id;
      } catch (e) {
        throw e;
      }
    }

    Future<void> sendMessage() async {
      try {
        String message = _messageController.text;

        if (message.isEmpty) {
          throw EasyLoading.showError("Please write some message first");
        }

        _messageController.clear();

        final String roomId = await createRoom();
        final UserModel currentUser =
            Provider.of<UserProvider>(context, listen: false).user as UserModel;

        CollectionReference chats = FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .collection("chats");

        DocumentReference doc = await chats.add({
          "sender": currentUser.id,
          "receiver": otherUser.id,
          "message": message,
          "createdAt": FieldValue.serverTimestamp(),
        });
        await doc.set({"id": doc.id}, SetOptions(merge: true));
      } catch (e) {
        EasyLoading.showError("$e");
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leadingWidth: 100,
        leading: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              SizedBox(width: 10),
              Icon(Icons.arrow_back),
              SizedBox(width: 10),
              CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, color: Colors.deepPurple),
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
        titleSpacing: 0,
        title: Text(otherUser.name),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Expanded(child: MessageStream(room: widget.room)),
            Divider(
              color: Colors.deepPurple,
              height: 0,
              thickness: 1,
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Icon(Icons.image, color: Colors.deepPurple),
                  SizedBox(width: 20),
                  Expanded(
                    child: MyTextField(
                      hint: 'Type message...',
                      controller: _messageController,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        sendMessage();
                      });
                    },
                    icon: const Icon(Icons.send_rounded, size: 35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
