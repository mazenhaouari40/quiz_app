import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/services/utils.dart';
import 'package:quiz_app/quiz_flow.dart';
import 'services/auth.dart';
import 'CreateQuizPage.dart';
import 'UpdateQuiz.dart'; // Add this import
import 'widgets/custom_appbar.dart';
import 'services/quiz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'services/quiz.dart';

enum quizState { waiting, count_down, started, leader_board, finished }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> quizzes = [];
  UniqueCodeGenerator code_generator = UniqueCodeGenerator(maxSize: 1000);
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    final currentUserId = Auth().currentUser?.uid;

    // Return early if user is not logged in
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to view quizzes')),
      );
      return;
    }

    try {
      final userQuizzes = await _quizService.fetchUserQuizzes(currentUserId);

      setState(() {
        quizzes = userQuizzes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quizzes: ${e.toString()}')),
      );
    }
  }

  Future<void> createAndActivateQuiz({
    required BuildContext context,
    required Map<String, dynamic> quiz,
  }) async {
    try {
      // Generate necessary data
      // Generate necessary data with null checks
      final quizId = quiz['id'] ;
      final userId = quiz['createdBy'] ;
      final invitationCode = code_generator.generateCode();

      if (quizId == 'default_quiz_id' || userId == 'default_user_id') {
        throw Exception('Quiz ID or User ID is missing');
      }

      final activeid = await _quizService.activateQuiz(
        invitationCode,
        quizId,
        userId,
      );

      if (activeid != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => WaitingPage(
                  activequizId: activeid,
                  userId: userId,
                  invitation_code: invitationCode,
                  quizid: quizId,
                ),
          ),
        );
      } else {
        throw Exception('Failed to activate quiz');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to create and activate quiz: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "HomePage"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text("New Quiz", style: TextStyle(fontSize: 14)),
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: 200,
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5, // Adjusted for buttons
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return Card(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                quiz['name']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Play Button (Green)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await createAndActivateQuiz(
                                        context: context,
                                        quiz: quiz,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        54,
                                        244,
                                        76,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "Play",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  // Update Button
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => UpdateQuiz(
                                                quizId: quiz['id']!,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text("Update"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                          onTap: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text('Are you sure you want to delete this quiz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false), // Cancel
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true), // Confirm
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete == true) {
                              await QuizService().deleteQuiz(quiz['id']!);

                              setState(() {
                                quizzes.removeWhere((q) => q['id'] == quiz['id']);
                              });
                            }
                          },
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
