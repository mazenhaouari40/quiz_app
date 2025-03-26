
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a new quiz to Firestore
  Future<void> saveNewQuiz(Map<String, dynamic> quiz) async {
    try {
      // Create a new document reference with auto-generated ID
      final newQuizRef = _db.collection('quizzes').doc();
      final newQuizId = newQuizRef.id;

      // Create sanitized quiz data
      final sanitizedQuiz = {
        'id': newQuizId,
        'quizName': quiz['quizName'],
        'totalDuration': quiz['totalDuration'],
        'totalMarks': quiz['totalMarks'],
        'createdBy': quiz['user']['uid'],
        'quizzes': quiz['quizzes'],
      };

      // Set the document data
      await newQuizRef.set(sanitizedQuiz);

      Fluttertoast.showToast(
        msg: "Quiz saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save quiz",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // Fetch quizzes created by a specific user
  Future<List<Map<String, dynamic>>?> fetchUserQuizzes(Map<String, dynamic> user) async {
    try {
      final query = _db
          .collection('quizzes')
          .where('createdBy', isEqualTo: user['uid']);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      return null;
    }
  }
}
