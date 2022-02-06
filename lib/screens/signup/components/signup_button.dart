import 'package:chat_app/screens/inbox/inbox_screen.dart';
import 'package:chat_app/widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SignupButton extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignupButton({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyButton(
      title: 'Signup',
      onPressed: () => register(context),
    );
  }

  Future<void> register(BuildContext context) async {
    try {
      EasyLoading.show(status: 'loading...');
      final userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      
      CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        await users.doc(userCredentials.user?.uid).set({
          "name": nameController.text,
          "email": emailController.text,
          "id": userCredentials.user?.uid,
          "dateTime": DateTime.now()
        });

        EasyLoading.showSuccess('Successful');
        Navigator.of(context).pushNamed('/');
        
    } on FirebaseAuthException catch (e) {
        EasyLoading.showError(e.message as String);
      }

      EasyLoading.dismiss();
  }
}
