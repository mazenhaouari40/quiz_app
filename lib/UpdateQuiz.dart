import 'package:flutter/material.dart';

class UpdateQuiz extends StatelessWidget {
  final String quizId;

  const UpdateQuiz({required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Quiz'),
      ),
      body: Center(
        child: Text('Editing Quiz ID: $quizId'),
      ),
    );
  }
}