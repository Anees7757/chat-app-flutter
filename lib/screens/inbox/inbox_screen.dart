import 'dart:async';

import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'components/recipient_item.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<dynamic> conversations = [];
  List<dynamic> newUsers = [];
  StreamSubscription<dynamic>? chatSubscription;

  @override
  void initState() {
    super.initState();
      fetchData();
  }

  void fetchData() {

    Stream collectionStream = FirebaseFirestore.instance
        .collection('users')
        .where("id",
            isNotEqualTo:
                Provider.of<UserProvider>(context, listen: false).user!.id)
        .snapshots();

    if (chatSubscription != null) {
      chatSubscription!.cancel();
    }

    chatSubscription = collectionStream.listen((event) async {
      List<Future> futures = [];

      event.docs.forEach((doc) {
        futures.add(fetchLastMessage(doc.data()));
      });

      // List<Map<String, dynamic>> data = Future.;
      List<dynamic> data = await Future.wait(futures);
      final List<dynamic> conversationList = [];
      final List<dynamic> newUsersList = [];

      data.forEach((item) {
        if (item["lastMessage"] != null) {
          conversationList.add(item);
        } else {
          newUsersList.add(item);
        }
      });

      setState(() {
        conversations = conversationList;
        newUsers = newUsersList;
      });
      EasyLoading.dismiss();
    });
  }

  Future<Map<String, dynamic>?> fetchLastMessage(
      Map<String, dynamic> data) async {
    try {
      final UserModel currentUser =
          Provider.of<UserProvider>(context, listen: false).user as UserModel;
      final CollectionReference roomsCollection =
          FirebaseFirestore.instance.collection('rooms');
      final QuerySnapshot rooms = await roomsCollection
          .where("users.${currentUser.id}", isEqualTo: true)
          .where("users.${data["id"]}", isEqualTo: true)
          .limit(1)
          .get();

      print("size " + rooms.size.toString());

      if (rooms.size > 0) {
        final String roomId = rooms.docs[0].id;
        final CollectionReference chatCollection = FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .collection("chats");
        final QuerySnapshot messages = await chatCollection
            .orderBy("createdAt", descending: true)
            .limit(1)
            .get();
        final Map<String, dynamic>? lastMessage = (messages.size > 0
            ? messages.docs[0].data()
            : null) as Map<String, dynamic>?;
        return {"user": data, "lastMessage": lastMessage, "roomId": roomId};
      }

      return {"user": data};
    } catch (e) {
      throw e;
    }
  }

  @override
  void dispose() {
    super.dispose();

    chatSubscription!.cancel();
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> logout() async {
      try {
        setState(() async{
          EasyLoading.show(status: 'loading...');

        await auth.signOut();

        EasyLoading.showInfo('Signout');
        Navigator.of(context).pushNamed('/');
        });
      } on FirebaseAuthException catch (e) {
        EasyLoading.showError(e.message as String);
      }

      EasyLoading.dismiss();
    }

  @override
  Widget build(BuildContext context) {
    Future<void> goToChat(Map<String, dynamic> selectedUser) async {
      Map<String, dynamic> arguments = {
        "selectedUser": selectedUser["user"],
        "roomId": selectedUser["roomId"]
      };

      await Navigator.of(context).pushNamed("/chat", arguments: arguments);

      fetchData();
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
          backgroundColor: Colors.deepPurple,
          title: Text("Chat App"),
          elevation: 0.0,
          actions: [
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => logout(),
                ),
          ]),
      body: Column(
        children: [
          Container(
            color: Colors.deepPurple,
            height: 30,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              margin: EdgeInsets.only(
                                  left: 28, right: 28, bottom: 15, top: 8),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 1))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Conversations",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            for (var item in conversations)
                              RecipientItem(
                                  onTap: () {
                                    goToChat(item);
                                  },
                                  message:
                                      MessageModel.fromMap(item["lastMessage"]),
                                  user: UserModel.fromMap(item["user"])),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              margin: EdgeInsets.only(
                                  left: 28, right: 28, bottom: 15, top: 8),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 1))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "All Users",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            for (var item in newUsers)
                              RecipientItem(
                                  onTap: () {
                                    goToChat(item);
                                  },
                                  user: UserModel.fromMap(item["user"])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
