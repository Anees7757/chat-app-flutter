// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;

  const MyTextField({
    required this.hint,
    required this.controller,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: (obscureText == true)
          ? 1
          : 5,
      minLines: 1,
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.purple,
      decoration: InputDecoration(
        hintText: hint,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }
}
