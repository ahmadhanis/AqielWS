// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, empty_catches, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mathwizard/gamea/gameascreen.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/leaderboard.dart';
import 'package:mathwizard/models/user.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;

class GameAMainScreen extends StatefulWidget {
  User user;

  GameAMainScreen({super.key, required this.user});

  @override
  _GameAMainScreenState createState() => _GameAMainScreenState();
}

class _GameAMainScreenState extends State<GameAMainScreen> {
  String selectedDifficulty = 'Beginner'; // Default difficulty
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
    loadLeader("Quik Math");
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "🧠 Quik Math",
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 20),

              // Difficulty Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "🎯 Pick Your Challenge Level!",
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
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "🎁 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct answer!",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Operation Buttons
              Column(
                children: [
                  const Text(
                    "🧮 Choose an Operation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildOperationButton(context, "➕", '+', Colors.green),
                      _buildOperationButton(context, "➖", '-', Colors.orange),
                      _buildOperationButton(context, "✖️", '×', Colors.blue),
                      _buildOperationButton(context, "➗", '÷', Colors.purple),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildOperationButton(
    BuildContext context,
    String operation,
    String realop,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: () async {
        if (int.parse(widget.user.dailyTries.toString()) > 0) {
          final shouldDeduct = await _showConfirmDialog(context);

          if (shouldDeduct) {
            final success = await _deductDailyTry();
            if (success) {
              AudioService.playSfx('sounds/start.mp3');
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GameAScreen(
                        user: widget.user,
                        operation: realop,
                        difficulty: selectedDifficulty,
                      ),
                ),
              );
              // Update UI after successful deduction
              _reloadUser();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Failed to update daily tries. Please try again.",
                  ),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "You have no daily tries remaining. Please try again tomorrow.",
              ),
            ),
          );
        }
      },
      child: Text(
        operation,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  _reloadUser() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/reload_user.php",
      ); // Changed to HTTP

      final response = await http.post(
        url,
        body: {'userid': widget.user.userId.toString()},
      );

      // Debug output

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user = User.fromJson(responseBody['data']);
          });
        }
      }
    } catch (e) {
      // Handle error silently
      print("Error reloading user: $e");
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Deduct a Try"),
                content: Text(
                  "Are you sure you want to use one daily from your [${widget.user.dailyTries} try/tries] for this game?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Yes"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<bool> _deductDailyTry() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/update_tries.php",
      ); // Changed to HTTP

      final response = await http.post(
        url,
        body: {'userid': widget.user.userId},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
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
}
