// createquiz.dart
import 'package:flutter/material.dart';
import 'widgets/custom_appbar.dart'; // Import the new appbar

class CreateQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Createquizapp",
        // Optional: You can pass a custom sign out function
        // onSignOut: () => yourCustomSignOutLogic(),
      ),
      body: Center(
        child: Text('Quiz Creation Page'),
      ),
    );
  }
}