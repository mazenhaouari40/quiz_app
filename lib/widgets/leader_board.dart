import 'package:flutter/material.dart';
  

Widget LeaderboardScreen(
  List<Map<String, dynamic>> participantsData,
  bool _isHost,
  String _gameStatus, {
  VoidCallback? onNextQuestion,
}) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF0E0E52),
      centerTitle: true,
      title: const Text(
        "Leaderboard",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    backgroundColor: const Color(0xFF1A1A40),
    body: Column(
      children: [
        // Add Finished Banner if game is over
        if (_gameStatus == "finished")
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.redAccent.withOpacity(0.2),
            child: const Text(
              "FINISHED",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: participantsData.length,
              itemBuilder: (context, index) {
                final participant = participantsData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212A6B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "#${index + 1}",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            participant['displayName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        participant['score'].toString(),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        
        Visibility(
          visible: _isHost && _gameStatus != "finished",
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF36F44C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Next Question",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}