import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';

class ResultfScreen extends StatelessWidget {
  final int score;
  final User user;
  final String difficulty;

  const ResultfScreen({
    super.key,
    required this.score,
    required this.user,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWin = score > 0;

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("⏱ Time Trial Pyramid Result"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isWin
                    ? "🎯 Great job solving pyramids!"
                    : "⛔ Time's up! Try again!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isWin ? Colors.green : Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              Text(
                "Coins Earned: $score",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Coin and Tries Summary
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Total Coins: ${user.coin}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.replay, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            "Daily Tries Left: ${user.dailyTries}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Return Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  "Back to Menu",
                  style: TextStyle(fontFamily: 'ComicSans'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
