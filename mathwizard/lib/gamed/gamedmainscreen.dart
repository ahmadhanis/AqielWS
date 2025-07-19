// ignore_for_file: use_build_context_synchronously, empty_catches, must_be_immutable

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/leaderboard.dart';
import 'package:mathwizard/models/user.dart';
import 'gamedscreen.dart'; // Replace with actual Game D screen when ready

class GameDMainScreen extends StatefulWidget {
  User user;

  GameDMainScreen({super.key, required this.user});

  @override
  State<GameDMainScreen> createState() => _GameDMainScreenState();
}

class _GameDMainScreenState extends State<GameDMainScreen> {
  String selectedDifficulty = 'Beginner';

  final Map<String, List<int>> difficultyTargetRanges = {
    'Beginner': [10, 20],
    'Intermediate': [21, 40],
    'Advanced': [41, 60],
  };

  int target = 0;

  final Map<String, int> difficultyPoints = {
    'Beginner': 2,
    'Intermediate': 4,
    'Advanced': 6,
  };
  List<Leaderboard> leaderboard = [];
  late double screenWidth, screenHeight;
  @override
  void initState() {
    super.initState();
    final range = difficultyTargetRanges[selectedDifficulty]!;
    target = Random().nextInt(range[1] - range[0] + 1) + range[0];
    loadLeader("Equation Builder");
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
    // final screenWidth = MediaQuery.of(context).size.width;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "🧩 Equation Builder",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Player Info
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Player Info",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.user.fullName.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.user.email.toString(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: Colors.orange,
                                size: 30,
                              ),
                              const SizedBox(height: 5),
                              Text("Coins: ${widget.user.coin}"),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.replay,
                                color: Colors.green,
                                size: 30,
                              ),
                              const SizedBox(height: 5),
                              Text("Tries: ${widget.user.dailyTries}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Difficulty selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "🚩 Choose Difficulty",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDifficulty,
                        dropdownColor: Colors.lightBlue[100],
                        items: const [
                          DropdownMenuItem(
                            value: 'Beginner',
                            child: Text("🟢 Beginner"),
                          ),
                          DropdownMenuItem(
                            value: 'Intermediate',
                            child: Text("🟠 Intermediate"),
                          ),
                          DropdownMenuItem(
                            value: 'Advanced',
                            child: Text("🔴 Advanced"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value!;
                            final range =
                                difficultyTargetRanges[selectedDifficulty]!;
                            target =
                                Random().nextInt(range[1] - range[0] + 1) +
                                range[0];
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "🎯 Target: $target",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct Equation!",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("✔️ Drag and drop equations to solve."),
                        Text("✔️ Click check answer to verify your answer."),
                        Text("✔️ Solve math equations quickly to score coins."),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Start Button
              ElevatedButton.icon(
                onPressed: () async {
                  if (int.parse(widget.user.dailyTries.toString()) > 0) {
                    final confirm = await _showConfirmDialog(context);
                    if (confirm) {
                      final success = await _deductDailyTry();
                      if (success) {
                        AudioService.playSfx('sounds/start.mp3');
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => GameDScreen(
                                  user: widget.user,
                                  difficulty: selectedDifficulty,
                                  target: target,
                                ),
                          ),
                        );
                        _reloadUser();
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No tries left. Try again tomorrow!"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  "Start Game",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Start Equation Builder?"),
                content: Text(
                  "This will use 1 try. Remaining tries: ${widget.user.dailyTries}",
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
    } catch (e) {}
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
            // widget.user.coin = data['data']['coin'];
            // widget.user.dailyTries = data['data']['daily_tries'];
            // print("${widget.user.dailyTries} tries left after reload");
          });
        }
      }
    } catch (e) {}
  }
}
