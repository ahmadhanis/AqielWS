import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';

class ResultbScreen extends StatelessWidget {
  final int score;
  final User user;

  const ResultbScreen({super.key, required this.score, required this.user});

  @override
  Widget build(BuildContext context) {
    bool isWin = score > 0;
    return Scaffold(
      appBar: AppBar(title: const Text("Game Over"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Score
            Text(
              isWin ? "🎉 Great Sequencer!" : "😢 Better Luck Next Time!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isWin ? Colors.green : Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "Your Score: $score",
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Play Again Button
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.popUntil(context, (route) => route.isFirst);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: const Text(
            //     "Play Again",
            //     style: TextStyle(fontSize: 18),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
