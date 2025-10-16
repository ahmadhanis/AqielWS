// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';

class ResultHScreen extends StatelessWidget {
  final User user;
  final int score;
  final String difficulty;

  /// Optional: called after popping when the user taps "Play Again".
  final VoidCallback? onPlayAgain;

  const ResultHScreen({
    super.key,
    required this.user,
    required this.score,
    required this.difficulty,
    this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWin = score > 0;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("🔚 Budget Hero • Results"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    isWin ? "🎉 Nice budgeting!" : "Keep practicing!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isWin ? Colors.green[700] : Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Difficulty: $difficulty",
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Score card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                              const Icon(Icons.stars, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                "Final Score: $score",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              _statChip(
                                icon: Icons.person,
                                label: user.fullName ?? "Player",
                              ),
                              _statChip(
                                icon: Icons.monetization_on,
                                label: "Coins: ${user.coin}",
                              ),
                              _statChip(
                                icon: Icons.replay,
                                label: "Tries Left: ${user.dailyTries}",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🧠 Tips",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• Combine small items to match the target closely.",
                        ),
                        Text(
                          "• Watch the remaining amount; avoid overspending.",
                        ),
                        Text(
                          "• Exact match = +5 bonus. Three exact matches add +10s!",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        child: OutlinedButton.icon(
                          onPressed:
                              () => Navigator.pop(context), // back to menu
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Back to Menu"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.teal.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // close results
                            onPlayAgain?.call();
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Play Again"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.green[50],
    );
  }
}
