// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:chat_app/screens/login/components/login_button.dart';
import 'package:chat_app/screens/signup/signup_screen.dart';
import 'package:chat_app/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Icon(Icons.chat_bubble, color: Colors.deepPurple, size: 90),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.chat_rounded,
                          color: Colors.purpleAccent, size: 90),
                    ),
                  ],
                ),
                const SizedBox(height: 135),
                MyTextField(hint: 'Email', controller: _emailController),
                const SizedBox(height: 10),
                MyTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 50),
                LoginButton(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New to the app?'),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      ),
                      child: const Text('Signup',
                          style: TextStyle(color: Colors.purpleAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
}
