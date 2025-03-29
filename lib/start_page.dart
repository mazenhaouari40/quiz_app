import 'package:flutter/material.dart';
import 'package:quiz_app/login_register.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/join_quiz_widget.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key, required this.onStart});

  final VoidCallback onStart;
  //const StartPage({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Quiz App", onLoginPressed: onStart),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            JoinQuizWidget(), // Input Form
            SizedBox(height: 10),

            // Title & Description
            Text(
              "How will you engage your audience?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Transform presentations into engaging conversations with interactive polls for meetings and classrooms.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Buttons
            ElevatedButton(
              onPressed: onStart,
              /*() {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }*/
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded edges
                ),
              ),
              child: const Text(
                "Get started",
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
