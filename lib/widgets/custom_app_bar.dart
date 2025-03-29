import 'package:flutter/material.dart';

AppBar customAppBar({
  required String title,
  required VoidCallback onLoginPressed,
}) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
    actions: [
      // Log in Button (Text Only)
      TextButton(
        onPressed: onLoginPressed,
        child: const Text(
          "Log in",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    ],
  );
}
