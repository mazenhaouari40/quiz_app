import 'package:flutter/material.dart';

Widget LeaderboardScreen(
  List<Map<String, dynamic>> participantsData,
  bool _isHost,
  String _gameStatus,
  String  _currentUserId,{
  VoidCallback? onNextQuestion,
}) {

  return Scaffold(

    appBar: _isHost? AppBar(
      backgroundColor: const Color(0xFF0E0E52),
      centerTitle: true,
      title: const Text(
        "Leaderboard",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ):null,

    backgroundColor: const Color(0xFF1A1A40),
    body: Column(
      children: [
        // Show 'FINISHED' banner if game is finished
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

        // Spread conditional widgets
        ...[
          if (_isHost)
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
            )
          else
          //yazid don t forget to design it well
            Expanded(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: participantsData
                  .where((p) => p['userid'] == _currentUserId)
                  .map((participant) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212A6B),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Score",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  participant['displayName'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  participant['score'].toString(),
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        )


        ],

        // Show 'Next Question' button for host only if game is not finished
        if (_isHost && _gameStatus != "finished")
          Padding(
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
      ],
    ),
  );
}
