
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a new quiz to Firestore
  Future<bool> saveNewQuiz(Map<String, dynamic> quiz) async {
    try {
      // Create a new document reference with auto-generated ID
      final newQuizRef = _db.collection('quizzes').doc();
      final newQuizId = newQuizRef.id;

      // Create  quiz data
      final Quizdata = {
        'id': newQuizId,
        'quizName': quiz['quizName'],
        'totalMarks': 0,
        'createdBy': quiz['user'],
        'questions': quiz['questions'],
      };

      // Set the document data
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

  Future<List<Map<String, dynamic>>> fetchUserQuizzes(String userId) async {
    try {
      final snapshot = await _db
          .collection('quizzes')
          .where('createdBy', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['quizName'] as String,
          // Include other fields you need
        };
      }).toList();
    } catch (e) {
      print('Error fetching user quizzes: $e');
      throw e;
    }
  }





}
