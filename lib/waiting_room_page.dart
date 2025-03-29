import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/quiz.dart';
enum GameStatus {
  waiting,
  countdown,
  started,
  leaderboard,
  finished,
}
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
//variable to set status
  int _currentQuizNumber = -1;
  GameStatus _gameStatus = GameStatus.waiting;
  bool _isHost = false;
  StreamSubscription? _quizSubscription;
  List<Map<String, dynamic>> _participantData = []; 
   
    GameStatus _parseGameStatus(String status) {
    switch (status) {
      case 'waiting': return GameStatus.waiting;
      case 'countdown': return GameStatus.countdown;
      case 'started': return GameStatus.started;
      case 'leaderboard': return GameStatus.leaderboard;
      case 'finished': return GameStatus.finished;
      default: return GameStatus.waiting;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  _setupFirebaseListener();
  }


Future<void> _removeUser(String participantId) async {
  try {
    if (participantId.isEmpty) {
      throw Exception('Participant ID cannot be empty');
    }

    await FirebaseFirestore.instance
        .collection('actived_Quizzes')  // Correct collection name
        .doc(widget.activequizId)       // Using widget's quiz ID
        .collection('participants')
        .doc(participantId)             // Directly use the passed document ID
        .delete();

    debugPrint('Successfully removed participant: $participantId');
  } catch (e) {
    debugPrint('Error removing participant: $e');
    rethrow; // Re-throw to let calling code handle the error
  }
}

 Future<void> _fetchParticipants() async {
    try {
      final query = await FirebaseFirestore.instance
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
    final activeQuizRef = FirebaseFirestore.instance
        .collection('actived_Quizzes')
        .doc(widget.activequizId);

    _quizSubscription = activeQuizRef.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _isHost = data['createdBy'] == widget.userId;
          _gameStatus = _parseGameStatus(data['status']);
         _currentQuizNumber = data['curQuestionNumber'] ?? -1;
          
        });
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
          _participantData = querySnapshot.docs.map((doc) => doc.data()).toList();
          
          // If new participant detected, navigate to all users screen
          if (mounted) {
            setState(() {
              _fetchParticipants();
            }); // Update UI with new participants
          }
        }
      });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _removeUser(widget.userId);
  }




  @override
  Widget build(BuildContext context) {

    // Create the participants list
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
                // "Start Quiz" Button
                Visibility(
          visible: _isHost,
               child: ElevatedButton(
                  onPressed: () async {
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
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button
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
}
