import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/widgets/count_down_widget.dart';
import 'package:quiz_app/widgets/leader_board.dart';
import 'services/quiz.dart';

List<Map<String, dynamic>> createParticipants(
  List<Map<String, dynamic>> participantData,
) {
  return participantData.map((data) {
    return {
      'display_name': data['displayName'],
      'score': data['score'] ?? 0,
      'id': data['userid'],
    };
  }).toList();
}

enum GameStatus { waiting, countdown, started, leaderboard, finished }

class WaitingPage extends StatefulWidget {
  final String activequizId;
  final String userId;
  final String invitation_code;

  WaitingPage({
    Key? key,
    required this.activequizId,
    required this.userId,
    required this.invitation_code,
  }) : super(key: key);

  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final QuizService _quizService = QuizService();
  int _currentQuizNumber = 0;
  GameStatus _gameStatus = GameStatus.waiting;
  bool _isHost = false;
  StreamSubscription? _quizSubscription;

  List<Map<String, dynamic>> _participantData = [];
  late Map<String, dynamic> currentQuestion;
  int? _numberquestion;

  GameStatus _parseGameStatus(String status) {
    switch (status) {
      case 'waiting':
        return GameStatus.waiting;
      case 'countdown':
        return GameStatus.countdown;
      case 'started':
        return GameStatus.started;
      case 'leaderboard':
        return GameStatus.leaderboard;
      case 'finished':
        return GameStatus.finished;
      default:
        return GameStatus.waiting;
    }
  }

  String gameStatusToString(GameStatus status) {
    switch (status) {
      case GameStatus.waiting:
        return 'waiting';
      case GameStatus.countdown:
        return 'countdown';
      case GameStatus.started:
        return 'started';
      case GameStatus.leaderboard:
        return 'leaderboard';
      case GameStatus.finished:
        return 'finished';
      default:
        return 'waiting';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuestion();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    _setupFirebaseListener();
  }

  Future<void> _loadQuestion() async {
    currentQuestion = await _quizService.fetchQuestionByIdFromActiveQuizzes(
      widget.activequizId,
      _currentQuizNumber,
    );
    _numberquestion = await _quizService.fetchNumberQuestions(
      widget.activequizId,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_gameStatus) {
      case GameStatus.waiting:
        return _waiting_room();
      case GameStatus.countdown:
        return _count_down();
      case GameStatus.started:
        return _question_screen();
      case GameStatus.leaderboard:
      case GameStatus.finished:
        return _buildleaderboardScreen();
    }
  }

  Widget _waiting_room() {
    List<Map<String, dynamic>> participants = createParticipants(
      _participantData,
    );

    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E), // Deep navy blue background
      appBar: AppBar(
        backgroundColor: Color(0xFF0E0E0E), // Black AppBar
        automaticallyImplyLeading: false, // Removes the back button
        title: null, // Removes default title
        flexibleSpace: Center(
          child: Text(
            'Quiz Code: ${widget.invitation_code}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Semi-transparent box
              borderRadius: BorderRadius.circular(20), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content height
              children: [
                // Animated "Waiting for players..."
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Waiting for players to join...",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: _isHost,
                  child: ElevatedButton(
                    onPressed: () async {
                      QuizService().changeGameStatus(
                        "countdown",
                        widget.activequizId,
                      );
                      /*Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => _count_down()),
                          );*/
                      // Convert participants list to map
                      // Uncommment and Modify this
                      /*Map<String, dynamic> participantsMap = {};
                        for (var participant in participants) {
                          participantsMap[participant['id']] = {
                            'display_name': participant['display_name'],
                            'score': participant['score'],
                          };
                        }

                        bool success = await _quizService.activateQuiz(
                          widget.invitation_code,
                          widget.quizId,
                          widget.userId,
                          participantsMap,
                        );

                        if (success) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
      }*/
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF36F44C), // Green button
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Rounded button
                      ),
                    ),
                    child: Text(
                      "Start Quiz",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Participants Grid
                Text(
                  "Participants (${participants.length})",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate the crossAxisCount based on available width
                      final crossAxisCount = constraints.maxWidth > 800 ? 6 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics:
                            participants.length > crossAxisCount * 2
                                ? AlwaysScrollableScrollPhysics()
                                : NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 3.5, // Adjusted for tighter boxes
                          mainAxisSpacing: 8, // Reduced spacing
                          crossAxisSpacing: 8, // Reduced spacing
                        ),
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final participant = participants[index];
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8, // Reduced horizontal padding
                              vertical: 4, // Reduced vertical padding
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Tight layout
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: Colors.white70,
                                  size: 16, // Smaller icon
                                ),
                                SizedBox(width: 6), // Reduced spacing
                                Flexible(
                                  child: Text(
                                    participant['display_name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14, // Slightly smaller font
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _removeUser(String participantId) async {
    try {
      if (participantId.isEmpty) {
        throw Exception('Participant ID cannot be empty');
      }

      await FirebaseFirestore.instance
          .collection('actived_Quizzes') // Correct collection name
          .doc(widget.activequizId) // Using widget's quiz ID
          .collection('participants')
          .doc(participantId) // Directly use the passed document ID
          .delete();

      debugPrint('Successfully removed participant: $participantId');
    } catch (e) {
      debugPrint('Error removing participant: $e');
      rethrow; // Re-throw to let calling code handle the error
    }
  }

  Future<void> _fetchParticipants() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('actived_Quizzes')
              .doc(widget.activequizId)
              .collection('participants')
              .get();

      _participantData = query.docs.map((doc) => doc.data()).toList();

      // Jouer les sons si nécessaire
    } catch (e) {
      print('Error fetching participants: $e');
    }
  }

  void _setupFirebaseListener() {
    //quiz listenner
    final activeQuizRef = FirebaseFirestore.instance
        .collection('actived_Quizzes')
        .doc(widget.activequizId);

    _quizSubscription = activeQuizRef.snapshots().listen((docSnapshot) {
      if (!mounted) return; // Check if widget is still in tree

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _isHost = data['createdBy'] == widget.userId;
          _gameStatus = _parseGameStatus(data['status']);
          _currentQuizNumber = data['num_actual_question'] ?? -1;
        });
        _loadQuestion();
      }
    });

    //participant listenner
    FirebaseFirestore.instance
        .collection('actived_Quizzes')
        .doc(widget.activequizId)
        .collection('participants')
        .snapshots()
        .listen((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            _participantData =
                querySnapshot.docs.map((doc) => doc.data()).toList();

            // If new participant detected, navigate to all users screen
            if (mounted) {
              setState(() {
                _fetchParticipants();
              }); // Update UI with new participants
            }
          }
        });
  }

  //question
  Widget _question_screen() {
    /* replace the question with the backend */
    /* final Map<String, dynamic> questionData = {
      "mappage": 0,
      "correctAnswers": [0, 1],
      "options": [
        "Neural Language Processing",
        "Natural Language Processing",
        "Non-Linear Processing",
        "Neural Learning Preparing",
      ],
      "question": "What does NLP stand for?",
      "tempsquestion": 10000,
    };*/

    final Map<String, dynamic> questionData = {
      "mappage": _currentQuizNumber, // Use default if null
      "correctAnswers": List<int>.from(currentQuestion['correctAnswers'] ?? []),
      "options": List<String>.from(currentQuestion['options'] ?? []),
      "question":
          currentQuestion['question'] ??
          currentQuestion['text'] ??
          'No question available',
      "tempsquestion":
          currentQuestion['tempsquestion'] ??
          currentQuestion['duration'] ??
          10000,
    };

    List<int> selectedAnswers = [];
    int timeLeft = questionData["tempsquestion"] ~/ 1000;
    int timeuser = timeLeft;
    List<int> correctAnswers =
        (questionData["correctAnswers"] as List).cast<int>();
    Timer? timer;

    return StatefulBuilder(
      builder: (context, setState) {
        // Start the timer only once
        if (timer == null || !timer!.isActive) {
          timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (timeLeft > 0) {
              setState(() => timeLeft--);
            } else {
              timer.cancel();
              if (!_isHost) {
                _quizService.setscoreparticipant(
                  selectedAnswers,
                  widget.userId,
                  timeuser,
                  widget.activequizId,
                  correctAnswers,
                );
              }
              QuizService().changeGameStatus(
                "leaderboard",
                widget.activequizId,
              );
            }
          });
        }

        final String questionText = questionData["question"] as String;
        final int mappage = questionData["mappage"] as int;
        final List<String> options =
            (questionData["options"] as List).cast<String>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF0E0E0E),
            centerTitle: true,
            title: Text(
              "Time Left: $timeLeft s",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionCard(questionText, mappage),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildOptionsList(options, selectedAnswers, (index) {
                    setState(() {
                      if (selectedAnswers.contains(index)) {
                        selectedAnswers.remove(index);
                      } else {
                        selectedAnswers.add(index);
                      }
                      timeuser = timeLeft;
                    });
                  }, setState),
                ),
                // _buildSubmitButton(selectedAnswers,correctAnswers),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(String questionText, int mappage) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${mappage + 1}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList(
    List<String> options,
    List<int> selectedAnswers,
    Function toggleSelection,
    StateSetter setState,
  ) {
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        bool isSelected = selectedAnswers.contains(index);
        return InkWell(
          onTap: () => toggleSelection(index),
          child: Card(
            color:
                isSelected
                    ? const Color.fromARGB(255, 49, 137, 83)
                    : Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      toggleSelection(index);
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* Widget _buildSubmitButton(List<int> selectedAnswers,List<int> correctAnswers) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          /* replace this with the score for the participant */

          print("Selected Answers: $selectedAnswers");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF36F44C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Submit Answer",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }*/

  /* Replace participant with the BE */
  /*List<Map<String, dynamic>> participantsData = [
    {'displayName': 'Alice', 'score': 90, 'userid': '001'},
    {'displayName': 'Bob', 'score': 80, 'userid': '002'},
    {'displayName': 'Charlie', 'score': 85, 'userid': '003'},
    {'displayName': 'David', 'score': 70, 'userid': '004'},
  ];*/

  /* List<Map<String, dynamic>> createParticipants(
    List<Map<String, dynamic>> participantData,
  ) {
    return participantData.map((data) {
      return {
        'display_name': data['displayName'],
        'score': data['score'] ?? 0,
        'id': data['userid'],
      };
    }).toList();
  }*/

  Widget _buildleaderboardScreen() {
    /*Replace this with the backend */
    // final participants = createParticipants(participantsData);
    return LeaderboardScreen(
      _participantData,
      _isHost,
      gameStatusToString(_gameStatus),
      onNextQuestion: () {
        // Handle next question navigation
        /* Replace this with the backend */
        if ((_currentQuizNumber + 1) < _numberquestion!) {
          QuizService().changeGameStatusandcurrentquestion(
            "countdown",
            widget.activequizId,
            _currentQuizNumber + 1,
          );
        } else {
          QuizService().changeGameStatus("finished", widget.activequizId);

          /*Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _count_down()),
              );*/
        }
      },
    );
  }

  Widget _count_down() {
    return CountdownScreen(
      onCountdownComplete: () {
        // This callback runs when countdown finishes
        /*  Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => _question_screen()),
        );*/
        QuizService().changeGameStatus("started", widget.activequizId);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _removeUser(widget.userId);
  }
}
