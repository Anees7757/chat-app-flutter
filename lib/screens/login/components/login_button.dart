// ignore_for_file: prefer_const_constructors

import 'package:chat_app/provider/provider.dart';
import 'package:chat_app/screens/inbox/inbox_screen.dart';
import 'package:chat_app/widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    required this.emailController,
    required this.passwordController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyButton(
      title: 'Login',
      onPressed: () => login(context),
    );
  }

  Future<void> login(
    BuildContext context,
  ) async {
    try {
      
        EasyLoading.show(status: 'loading...');

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');

        DocumentSnapshot<Object?> user =
            await users.doc(userCredential.user?.uid).get();

        EasyLoading.showSuccess('Successful');

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        emailController.clear();
        passwordController.clear();
        Navigator.of(context).pushNamed("/inbox");
    } on FirebaseAuthException catch (e) {
        EasyLoading.showError(e.message as String);
      }

      EasyLoading.dismiss();
  }
}
