import 'package:flutter/material.dart';
import 'package:quiz_app/home_page.dart';
import 'package:quiz_app/login_register.dart';
import 'package:quiz_app/start_page.dart';
import 'services/auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  bool showLogin = false; // Controls whether to show LoginPage

  void toggleLoginPage() {
    setState(() {
      showLogin = true; // When called, it shows LoginPage
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage(); // If user is authenticated, go to HomePage
        } else {
          return showLogin
              ? const LoginPage() // If button was clicked, show LoginPage
              : StartPage(onStart: toggleLoginPage); // Default page with button
        }
      },
    );
  }
}
