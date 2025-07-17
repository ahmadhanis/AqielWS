// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/models/user.dart';
import 'gamefscreen.dart'; // Replace with actual gameplay screen

class GameFMainScreen extends StatefulWidget {
  User user;

  GameFMainScreen({super.key, required this.user});

  @override
  State<GameFMainScreen> createState() => _GameFMainScreenState();
}

class _GameFMainScreenState extends State<GameFMainScreen> {
  String selectedDifficulty = 'Beginner';
  final Map<String, int> difficultyPoints = {
    'Beginner': 3,
    'Intermediate': 6,
    'Advanced': 9,
  };
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("🧮 Number Pyramid"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Player Info
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "👤 Player Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.user.fullName.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.user.email.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("🪙 Coins: ${widget.user.coin}"),
                        Text("🌀 Tries: ${widget.user.dailyTries}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Difficulty Selector
            const Text(
              "🎮 Choose Difficulty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedDifficulty,
              onChanged: (value) {
                setState(() => selectedDifficulty = value!);
              },
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text("🟢 Beginner")),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text("🟠 Intermediate"),
                ),
                DropdownMenuItem(value: 'Advanced', child: Text("🔴 Advanced")),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per solved pyramid!",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "📘 Game Instructions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "✔️ Fill in missing blocks using addition or subtraction.",
                  ),
                  Text(
                    "✔️ Complete as many pyramids as possible in 60 seconds.",
                  ),
                  Text("⏱️ Correct answers may add bonus time!"),
                ],
              ),
            ),

            const Spacer(),

            // Start Game Button
            ElevatedButton.icon(
              onPressed: () async {
                if (int.parse(widget.user.dailyTries.toString()) > 0) {
                  final shouldProceed = await _showConfirmDialog();
                  if (shouldProceed) {
                    final success = await _deductDailyTry();
                    if (success) {
                      await audioPlayer.play(AssetSource('sounds/start.mp3'));
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => GameFScreen(
                                user: widget.user,
                                difficulty: selectedDifficulty,
                              ),
                        ),
                      );
                      await _reloadUser();
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No tries left. Try again tomorrow."),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                "Start Game",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'ComicSans',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Start Time Trial Pyramid?"),
                content: Text(
                  "Use 1 try to play? You currently have ${widget.user.dailyTries} try/tries left.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<bool> _deductDailyTry() async {
    try {
      final response = await http.post(
        Uri.parse("https://slumberjer.com/mathwizard/api/update_tries.php"),
        body: {'userid': widget.user.userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            widget.user.dailyTries =
                (int.parse(widget.user.dailyTries.toString()) - 1).toString();
          });
          return true;
        }
      }
    } catch (e) {
      // Optionally handle error
    }
    return false;
  }

  Future<void> _reloadUser() async {
    try {
      final response = await http.post(
        Uri.parse("https://slumberjer.com/mathwizard/api/reload_user.php"),
        body: {'userid': widget.user.userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            widget.user = User.fromJson(data['data']);
          });
        }
      }
    } catch (e) {
      // Optionally handle error
    }
  }
}
