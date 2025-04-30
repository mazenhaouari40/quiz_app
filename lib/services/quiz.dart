import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quiz_app/services/utils.dart';


class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> activateQuiz(
    String invitationCode,
    String quizId,
    String userId,
  ) async {
    try {
      final activeQuizRef = _db.collection('actived_Quizzes').doc();
      final activeQuizId = activeQuizRef.id;

      final activeQuizData = {
        'id': activeQuizId,
        'quizzId': quizId,
        'num_actual_question': 0,
        'createdBy': userId,
        'status': 'waiting',
        'invitation_code': invitationCode,
      };

      await activeQuizRef.set(activeQuizData);

      return activeQuizId;
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveNewQuiz(Map<String, dynamic> quiz) async {
    try {
      final newQuizRef = _db.collection('quizzes').doc();
      final newQuizId = newQuizRef.id;

      final Quizdata = {
        'id': newQuizId,
        'quizName': quiz['quizName'],
        'createdBy': quiz['user'],
        'questions': quiz['questions'],
      };

      await newQuizRef.set(Quizdata);

      Fluttertoast.showToast(
        msg: "Quiz saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save quiz",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> updateQuiz(Map<String, dynamic> quiz, String quizId) async {
    try {
      final quizRef = _db.collection('quizzes').doc(quizId);

      final updatedQuizData = {
        'quizName': quiz['quizName'],
        'createdBy': quiz['user'],
        'questions': quiz['questions'],
      };

      await quizRef.update(updatedQuizData);

      Fluttertoast.showToast(
        msg: "Quiz updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update quiz: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchQuizById(String quizId) async {
    try {
      final docSnapshot = await _db.collection('quizzes').doc(quizId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return {
          'id': docSnapshot.id,
          'quizName': data['quizName'],
          'totalMarks': data['totalMarks'],
          'createdBy': data['createdBy'],
          'questions': List<Map<String, dynamic>>.from(data['questions']),
        };
      } else {
        throw Exception('Quiz not found');
      }
    } catch (e) {
      print('Error fetching quiz: $e');
      throw e; 
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserQuizzes(String userId) async {
    try {
      final snapshot =
          await _db
              .collection('quizzes')
              .where('createdBy', isEqualTo: userId)
              .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['quizName'] as String,
          'createdBy': doc['createdBy'] as String,
        };
      }).toList();
    } catch (e) {
      print('Error fetching user quizzes: $e');
      throw e;
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await _db.collection('quizzes').doc(quizId).delete();
      print('Quiz deleted successfully');
    } catch (e) {
      print('Error deleting quiz: $e');
      throw e;
    }
  }

  Future<void> changeGameStatus(String gameStatus, String activeQuizId) async {
    await _db.collection("actived_Quizzes").doc(activeQuizId).update({
      "status": gameStatus,
    });
  }

  Future<void> changeGameStatusandcurrentquestion(
    String gameStatus,
    String activeQuizId,
    int nextquestion,
  ) async {
    await _db.collection("actived_Quizzes").doc(activeQuizId).update({
      "num_actual_question": nextquestion,
      "status": gameStatus,
    });
  }
  
  Future<void> setscoreparticipant(
    List<int> selectedAnswers,
    String participantId,
    int timeuser,
    String activeQuizId,
    List<int> correctAnswers,
  ) async {
    try {
      final participantRef = FirebaseFirestore.instance
          .collection('actived_Quizzes')
          .doc(activeQuizId)
          .collection('participants')
          .doc(participantId);

      if (kDebugMode) {
        print(selectedAnswers);
        print(correctAnswers);
        print(timeuser);
      }

      debugPrint('$correctAnswers'); 
      int points =0;
      // 2. calculate points
      points = calculateScore(
        selectedAnswers,
        correctAnswers,
        timeuser as double,
      );
      
      // 4. Update participant data
      await participantRef.update({'score': FieldValue.increment(points)});

    } catch (e) {
      throw Exception('Failed to update participant score');
    }
  }

  
}
