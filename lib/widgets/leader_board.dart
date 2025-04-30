import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/AnimatedPodiumTile.dart';

Widget LeaderboardScreen(
  List<Map<String, dynamic>> participantsData,
  bool _isHost,
  String _gameStatus,
  String _currentUserId, {
  VoidCallback? onNextQuestion,
}) {
  final maxScore =
      participantsData.isNotEmpty
          ? participantsData
              .map((p) => p['score'] as int)
              .reduce((a, b) => a > b ? a : b)
          : 1;
  return Scaffold(
    appBar:
        _isHost
            ? AppBar(
              backgroundColor: const Color(0xFF0E0E52),
              centerTitle: true,
              title: const Text(
                "Leaderboard",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            : null,

    backgroundColor: const Color(0xFF1A1A40),
    body: Column(
      children: [
        // Show 'FINISHED' banner if game is finished
        if (_gameStatus == "finished" && _isHost)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.greenAccent,
              child: Column(
                children: [
                  const Text(
                    "FINAL RESULTS",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedTile(
                        delay: const Duration(milliseconds: 200),
                        name:
                            participantsData.length > 1
                                ? participantsData[1]['displayName']
                                : "Waiting...",
                        score:
                            participantsData.length > 1
                                ? participantsData[1]['score']
                                : 0,
                        height: 150,
                      ),
                      const SizedBox(width: 16),
                      AnimatedTile(
                        delay: const Duration(milliseconds: 400),
                        name:
                            participantsData.isNotEmpty
                                ? participantsData[0]['displayName']
                                : "Waiting...",
                        score:
                            participantsData.isNotEmpty
                                ? participantsData[0]['score']
                                : 0,
                        height: 180,
                      ),
                      const SizedBox(width: 16),
                      AnimatedTile(
                        delay: const Duration(milliseconds: 600),
                        name:
                            participantsData.length > 2
                                ? participantsData[2]['displayName']
                                : "Waiting...",
                        score:
                            participantsData.length > 2
                                ? participantsData[2]['score']
                                : 0,
                        height: 130,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Spread conditional widgets
        ...[
          // Score Board
          if (_isHost)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: participantsData.length,
                  itemBuilder: (context, index) {
                    var participant = participantsData[index];
                    double progress =
                        (participant['score'] as int) /
                        (maxScore == 0 ? 1 : maxScore);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212A6B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
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

                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  participant['displayName'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0,
                                        end: progress,
                                      ),
                                      duration: const Duration(seconds: 1),
                                      builder:
                                          (
                                            context,
                                            value,
                                            _,
                                          ) => LinearProgressIndicator(
                                            value: value,
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.greenAccent),
                                            minHeight: 8,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
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
            // Indiv Score
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212A6B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Your Score",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.greenAccent,
                            width: 5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          participantsData
                              .firstWhere(
                                (p) => p['userid'] == _currentUserId,
                              )['score']
                              .toString(),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
