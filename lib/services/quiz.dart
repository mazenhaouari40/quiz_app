import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum quizState { count_down, started, leader_board, finished }

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

  // Update an existing quiz in Firestore
  Future<bool> updateQuiz(Map<String, dynamic> quiz, String quizId) async {
    try {
      // Get a reference to the quiz document
      final quizRef = _db.collection('quizzes').doc(quizId);

      // Create updated quiz data
      final updatedQuizData = {
        'quizName': quiz['quizName'],
        'createdBy': quiz['user'],
        'questions': quiz['questions'],
      };

      // Update the document
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
          // Include any other fields you need
        };
      } else {
        throw Exception('Quiz not found');
      }
    } catch (e) {
      print('Error fetching quiz: $e');
      throw e; // Re-throw to let the caller handle it
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
          // Include other fields you need
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

  Future<bool> activateQuiz(
    String invitation_code,
    String quizId,
    String userId,
    Map<String, dynamic> participants,
  ) async {
    try {
      // Create a new document reference with auto-generated ID
      final newactQuizRef = _db.collection('actived_Quizzes').doc();
      final actQuizID = newactQuizRef.id;

      // Create  quiz data
      final actQuizdata = {
        'id': actQuizID,
        'quizzId': quizId,
        'num_actual_question': 0,
        'createdBy': userId,
        'invitation_code': invitation_code,
        'participants': participants,
      };

      // Set the document data
      await newactQuizRef.set(actQuizdata);

      /*Fluttertoast.showToast(
        msg: "Quiz saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );*/
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to start quiz",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }
}
