
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

Future<List<Map<String, dynamic>>?> fetchUserQuizzes(String userId) async {
  try {
    final query = _db
        .collection('quizzes')
        .where('createdBy', isEqualTo: userId); // Use userId directly

    final querySnapshot = await query.get();

    // Return the list of quizzes with their IDs and data
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>, // Ensure data is cast to the correct type
      };
    }).toList();
  } catch (e) {
    // Return null or handle the error accordingly
    return null;
  }
}



}
