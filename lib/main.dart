// ignore_for_file: prefer_const_constructors

import 'package:chat_app/provider/provider.dart';
import 'package:chat_app/screens/chat/chat_screen.dart';
import 'package:chat_app/screens/inbox/inbox_screen.dart';
import 'package:chat_app/screens/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'screens/signup/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) => UserProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      builder: EasyLoading.init(),
      routes: {
        '/': (context) => LoginScreen(),
        '/inbox': (context) => InboxScreen(),
        '/signup': (context) => SignupScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(room: args["roomId"], otherUser: args["selectedUser"]));
        }
        return null; // Let `onUnknownRoute` handle this behavior.
      },
    );
  }
}
