// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/leaderboard.dart';
import 'package:mathwizard/models/user.dart';
import 'gameescreen.dart'; // Placeholder for the actual game screen

class GameEMainScreen extends StatefulWidget {
  User user;

  GameEMainScreen({super.key, required this.user});

  @override
  State<GameEMainScreen> createState() => _GameEMainScreenState();
}

class _GameEMainScreenState extends State<GameEMainScreen> {
  String selectedDifficulty = 'Beginner';
  final Map<String, int> difficultyPoints = {
    'Beginner': 1,
    'Intermediate': 2,
    'Advanced': 3,
  };
  List<Leaderboard> leaderboard = [];
  late double screenWidth, screenHeight;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLeader("Math Runner");
  }

  loadLeader(String gameName) async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/leaderboard.php?game=${Uri.encodeComponent(gameName)}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // Debug output
        print("Leaderboard response: $responseBody");
        if (responseBody['status'] == 'success') {
          setState(() {
            // Assuming you have a leaderboard list in your state
            leaderboard =
                (responseBody['data'] as List)
                    .map((item) => Leaderboard.fromJson(item))
                    .toList();
          });
          // Optional UI feedback:
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("Leaderboard loaded successfully."),
          // ));
        }
      }
    } catch (e) {}
  }

  void _showLeaderboardDialog() {
    if (leaderboard.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Leaderboard for Quik Math"),
            content: SizedBox(
              width: 600, // Fixed width for dialog
              height: screenHeight / 2, // Fixed height for dialog
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = leaderboard[index];
                  return ListTile(
                    leading: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(entry.fullName),
                    subtitle: Text(
                      'School: ${entry.schoolCode} | Standard: ${entry.standard}',
                    ),
                    trailing: Text('${entry.coins} coins'),
                    tileColor:
                        int.parse(entry.rankId) <= 3
                            ? Colors.amber.withOpacity(
                              0.2 * (4 - int.parse(entry.rankId)),
                            )
                            : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leaderboard is empty or still loading.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("🏃‍♂️ Math Runner"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard, color: Colors.amber),
            onPressed: () {
              _showLeaderboardDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Player Info Card
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
              "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct gate!",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // Game Instructions
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
                  Text("✔️ Tap to choose the correct path."),
                  Text("✔️ Solve math gates quickly to score coins."),
                  Text("❌ Wrong answers reduce your chance to win."),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Start Game Button
            ElevatedButton.icon(
              onPressed: () async {
                if (int.parse(widget.user.dailyTries.toString()) > 0) {
                  final shouldProceed = await _showConfirmDialog();
                  if (shouldProceed) {
                    final success = await _deductDailyTry();
                    if (success) {
                      AudioService.playSfx('sounds/start.mp3');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => GameEScreen(
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
                title: const Text("Start Math Runner?"),
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
