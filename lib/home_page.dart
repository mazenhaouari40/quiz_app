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
  List<Map<String, dynamic>> filteredQuizzes = [];
  UniqueCodeGenerator code_generator = UniqueCodeGenerator(maxSize: 1000);
  final QuizService _quizService = QuizService();
  void filterQuizzes() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredQuizzes =
          quizzes.where((quiz) {
            final title = quiz['name'].toLowerCase();
            return title.contains(query);
          }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
    _searchController.addListener(() {
      filterQuizzes();
    });
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
        filteredQuizzes = userQuizzes; // initialize filtered list
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
      final quizId = quiz['id'];
      final userId = quiz['createdBy'];
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: "Home Page",
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
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
                        backgroundColor: Colors.black, // Black background
                        foregroundColor: Colors.white, // White text
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.black,
                          ), // Optional: black border
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        "New Quiz",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  filteredQuizzes.isEmpty
                      ? Center(
                        child: Text(
                          'No quizzes found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 188, 57, 57),
                          ),
                        ),
                      )
                      : GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250, // Max width for each item
                          childAspectRatio: 1.2, // Width/Height ratio
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredQuizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = filteredQuizzes[index];
                          return Card(
                            elevation: 6, // Stronger shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corners
                            ),
                            color: Colors.white, // White background
                            shadowColor: Colors.black26, // Softer shadow color
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                    16.0,
                                  ), // Increased padding for better breathing space
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        quiz['name']!,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ), // Add spacing between title and buttons
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
                                              backgroundColor: Color.fromARGB(
                                                255,
                                                54,
                                                244,
                                                76,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            child: Text(
                                              "Play",
                                              style: TextStyle(fontSize: 14),
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
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            child: Text(
                                              "Update",
                                              style: TextStyle(fontSize: 14),
                                            ),
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
                                      final shouldDelete = await showDialog<
                                        bool
                                      >(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm Delete'),
                                            content: Text(
                                              'Are you sure you want to delete this quiz?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (shouldDelete == true) {
                                        await QuizService().deleteQuiz(
                                          quiz['id']!,
                                        );

                                        setState(() {
                                          quizzes.removeWhere(
                                            (q) => q['id'] == quiz['id'],
                                          );
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
