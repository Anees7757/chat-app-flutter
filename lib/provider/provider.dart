import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(DocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

    _user = UserModel.fromMap(userData);

    notifyListeners();
  }

  void updateUser(Map<String, dynamic> userData) {
   // _user!.updateWith(userData);
    notifyListeners();
  }

  void resetUser() {
    _user = null;
  }
}