// ignore_for_file: library_private_types_in_public_api, empty_catches, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'gamebscreen.dart'; // Replace with the screen where the game logic will be implemented
import 'package:mathwizard/models/user.dart';

class GameBMainScreen extends StatefulWidget {
  User user; // User object to pass user details

  GameBMainScreen({required this.user, super.key});

  @override
  _GameBMainScreenState createState() => _GameBMainScreenState();
}

class _GameBMainScreenState extends State<GameBMainScreen> {
  String selectedDifficulty = 'Beginner'; // Default difficulty

  final Map<String, int> difficultyPoints = {
    'Beginner': 1,
    'Intermediate': 2,
    'Advanced': 3,
  };

  // Future<bool> _deductDailyTry() async {
  //   try {
  //     // Temp solution to bypass SSL certificate error
  //     HttpClient _createHttpClient() {
  //       final HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //       return httpClient;
  //     }

  //     final ioClient = IOClient(_createHttpClient());
  //     final url = Uri.parse(
  //       "https://slumberjer.com/mathwizard/api/update_tries.php",
  //     );
  //     final response = await ioClient.post(
  //       url,
  //       body: {'userid': widget.user.userId},
  //     );
  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);
  //       if (responseBody['status'] == 'success') {
  //         setState(() {
  //           widget.user.dailyTries =
  //               (int.parse(widget.user.dailyTries.toString()) - 1)
  //                   .toString(); // Update UI after successful deduction
  //         });
  //         return true;
  //       }
  //     }
  //   } catch (e) {
  //     print("Error deducting daily try: $e");
  //   }
  //   return false;
  // }

  Future<bool> _deductDailyTry() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/update_tries.php", // Use HTTP instead of HTTPS
      );

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
      }
    } catch (e) {}

    return false;
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

  // _reloadUser() async {
  //   try {
  //     // Temp solution to bypass SSL certificate error
  //     HttpClient _createHttpClient() {
  //       final HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //       return httpClient;
  //     }

  //     final ioClient = IOClient(_createHttpClient());
  //     final url = Uri.parse(
  //       "https://slumberjer.com/mathwizard/api/reload_user.php",
  //     );
  //     final response = await ioClient.post(
  //       url,
  //       body: {'userid': widget.user.userId.toString()},
  //     );
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);
  //       if (responseBody['status'] == 'success') {
  //         setState(() {
  //           widget.user = User.fromJson(responseBody['data']);
  //         });
  //         ("User info reloaded successfully.");
  //         // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         //   content: Text("User info reloaded successfully."),
  //         // ));
  //       } else {
  //         print("Error reloading user info: ${responseBody['message']}");
  //       }
  //     } else {
  //       print(
  //         "Failed to connect to server. Status code: ${response.statusCode}",
  //       );
  //     }
  //   } catch (e) {
  //     print("Error reloading user info: $e");
  //   }
  // }

  _reloadUser() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/reload_user.php", // Changed to HTTP
      );

      final response = await http.post(
        url,
        body: {'userid': widget.user.userId.toString()},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user = User.fromJson(responseBody['data']);
          });
        } else {}
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "🧩 Sequence Hunter",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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

              const SizedBox(height: 25),

              // Difficulty Selection
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
                    "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct sequence!",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Start Button
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
                                (_) => GameBScreen(
                                  user: widget.user,
                                  difficulty: selectedDifficulty,
                                ),
                          ),
                        );
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.videogame_asset, color: Colors.white),
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
}
