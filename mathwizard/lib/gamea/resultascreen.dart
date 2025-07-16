import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';

class ResultaScreen extends StatelessWidget {
  final int score;
  final User user;

  const ResultaScreen({super.key, required this.score, required this.user});

  @override
  Widget build(BuildContext context) {
    bool isWin = score > 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Game Over"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWin ? "🎉 Great Run!" : "😢 Better Luck Next Time!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isWin ? Colors.green : Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Display Score
            Text(
              "Coins Earned: $score",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Display Updated Coin and Tries
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Coins: ${user.coin}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Daily Tries Remaining: ${user.dailyTries}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Return Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
