// ignore_for_file: use_build_context_synchronously, empty_catches

import 'dart:convert';
// ignore: unused_import
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';
import 'gamecscreen.dart'; // Replace with the actual game screen for Math Maze

class GameCMainScreen extends StatefulWidget {
  final User user;

  const GameCMainScreen({super.key, required this.user});

  @override
  State<GameCMainScreen> createState() => _GameCMainScreenState();
}

class _GameCMainScreenState extends State<GameCMainScreen> {
  String selectedDifficulty = 'Beginner';

  final Map<String, List<int>> difficultyTargetRanges = {
    'Beginner': [10, 20],
    'Intermediate': [21, 40],
    'Advanced': [41, 60],
  };
  int target = 0;
  final Map<String, int> difficultyPoints = {
    'Beginner': 1,
    'Intermediate': 2,
    'Advanced': 3,
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final range = difficultyTargetRanges[selectedDifficulty]!;
    target = Random().nextInt(range[1] - range[0] + 1) + range[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "🧮 Math Maze",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Player Info Card
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

              // Difficulty selection
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
                      border: Border.all(color: Colors.blueAccent, width: 1),
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
                    "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct Maze Solve!",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Start Game Button
              ElevatedButton.icon(
                onPressed: () async {
                  if (int.parse(widget.user.dailyTries.toString()) > 0) {
                    final shouldDeduct = await _showConfirmDialog(context);
                    if (shouldDeduct) {
                      final success = await _deductDailyTry();
                      if (success) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => GameCScreen(
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
                title: const Text("Deduct a Try"),
                content: Text(
                  "Use one try to play the Math Maze? Remaining: ${widget.user.dailyTries}",
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

  // Future<bool> _deductDailyTry() async {
  //   try {
  //     final ioClient = IOClient(
  //       HttpClient()..badCertificateCallback = (cert, host, port) => true,
  //     );

  //     final response = await ioClient.post(
  //       Uri.parse("https://slumberjer.com/mathwizard/api/update_tries.php"),
  //       body: {'userid': widget.user.userId},
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['status'] == 'success') {
  //         setState(() {
  //           widget.user.dailyTries =
  //               (int.parse(widget.user.dailyTries.toString()) - 1).toString();
  //         });
  //         return true;
  //       }
  //     }
  //   } catch (e) {
  //     print("Error deducting try: $e");
  //   }
  //   return false;
  // }
  Future<bool> _deductDailyTry() async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://slumberjer.com/mathwizard/api/update_tries.php",
        ), // Changed to HTTP
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
      } else {}
    } catch (e) {}
    return false;
  }
  // Future<void> _reloadUser() async {
  //   try {
  //     final ioClient = IOClient(
  //       HttpClient()..badCertificateCallback = (cert, host, port) => true,
  //     );

  //     final response = await ioClient.post(
  //       Uri.parse("https://slumberjer.com/mathwizard/api/reload_user.php"),
  //       body: {'userid': widget.user.userId},
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['status'] == 'success') {
  //         setState(() {
  //           widget.user.coin = data['data']['coin'];
  //           widget.user.dailyTries = data['data']['dailyTries'];
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print("Reload error: $e");
  //   }
  // }

  Future<void> _reloadUser() async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://slumberjer.com/mathwizard/api/reload_user.php",
        ), // Changed to HTTP
        body: {'userid': widget.user.userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            widget.user.coin = data['data']['coin'];
            widget.user.dailyTries = data['data']['dailyTries'];
          });
        } else {}
      } else {}
    } catch (e) {}
  }
}
