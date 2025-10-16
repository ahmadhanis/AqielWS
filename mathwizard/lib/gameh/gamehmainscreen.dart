import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:mathwizard/models/user.dart';
import 'gamehscreen.dart'; // actual gameplay screen

class GameHMainScreen extends StatefulWidget {
  final User user;
  const GameHMainScreen({super.key, required this.user});

  @override
  State<GameHMainScreen> createState() => _GameHMainScreenState();
}

class _GameHMainScreenState extends State<GameHMainScreen> {
  String selectedDifficulty = 'Beginner';
  final Map<String, int> difficultyPoints = {
    'Beginner': 1,
    'Intermediate': 2,
    'Advanced': 3,
  };
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("💰 Budget Hero"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlayerInfo(),
            const SizedBox(height: 20),
            _buildDifficultySelector(),
            const SizedBox(height: 25),
            _buildInstructions(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildStartButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "👤 Player Info",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.fullName ?? "Player",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.user.email ?? "",
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
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      children: [
        const Text(
          "🎮 Choose Difficulty",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedDifficulty,
          onChanged: (value) => setState(() => selectedDifficulty = value!),
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
          "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct budget!",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
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
            "📘 Game Instructions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("✔️ Select items without exceeding your budget."),
          Text("✔️ Each round has a different target amount."),
          Text("✔️ Get as close as possible — exact match = bonus!"),
          Text("⏱️ You have 60 seconds per round."),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await audioPlayer.play(AssetSource('sounds/start.mp3'));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => GameHScreen(
                  user: widget.user,
                  difficulty: selectedDifficulty,
                ),
          ),
        );
      },
      icon: const Icon(Icons.play_arrow),
      label: const Text(
        "Start Game",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[700],
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
