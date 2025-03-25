import 'package:flutter/material.dart';

AppBar customAppBar({
  required String title,
  required VoidCallback onLoginPressed,
  required VoidCallback onSignUpPressed,
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
      // Sign Up Button (Styled)
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 10), // Spacing
        child: ElevatedButton(
          onPressed: onSignUpPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded edges
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ), // Size
          ),
          child: const Text(
            "Sign up",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ],
  );
}
