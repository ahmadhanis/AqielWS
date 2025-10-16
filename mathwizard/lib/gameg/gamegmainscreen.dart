// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/gameg/gamegscreen.dart';
import 'package:mathwizard/models/user.dart';
// import 'gamegscreen.dart'; // TODO: create and wire your gameplay screen

class GameGMainScreen extends StatefulWidget {
  User user;
  GameGMainScreen({super.key, required this.user});

  @override
  State<GameGMainScreen> createState() => _GameGMainScreenState();
}

class _GameGMainScreenState extends State<GameGMainScreen> {
  final AudioPlayer _audio = AudioPlayer();

  String selectedDifficulty = 'Beginner';
  String selectedMode = 'Prime Finder';

  final Map<String, int> difficultyPoints = const {
    'Beginner': 1,
    'Intermediate': 2,
    'Advanced': 3,
  };

  // Suggested number ranges per difficulty (for use in GameGScreen)
  final Map<String, List<int>> difficultyRanges = const {
    'Beginner': [1, 50],
    'Intermediate': [1, 150],
    'Advanced': [1, 500],
  };

  final List<String> modes = const [
    'Prime Finder', // tap only primes
    'Composite Catch', // tap only composites
    'Twin Prime Rush', // tap twin pairs (p, p+2)
  ];

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("🧪 Prime Time"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPlayerCard(),
                  const SizedBox(height: 16),
                  _buildDifficultyPicker(),
                  const SizedBox(height: 12),
                  _buildModePicker(isWide: isWide),
                  const SizedBox(height: 18),
                  _buildInstructions(),
                  const SizedBox(height: 24),
                  _buildPreviewChips(),
                  const SizedBox(height: 24),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard() {
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
                _stat("🪙 Coins", widget.user.coin.toString()),
                _stat("🌀 Tries", widget.user.dailyTries.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyPicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🎮 Choose Difficulty",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDifficulty,
                items: const [
                  DropdownMenuItem(
                    value: 'Beginner',
                    child: Text("🟢 Beginner (1–50)"),
                  ),
                  DropdownMenuItem(
                    value: 'Intermediate',
                    child: Text("🟠 Intermediate (1–150)"),
                  ),
                  DropdownMenuItem(
                    value: 'Advanced',
                    child: Text("🔴 Advanced (1–500)"),
                  ),
                ],
                onChanged: (v) => setState(() => selectedDifficulty = v!),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "🏆 Earn ${difficultyPoints[selectedDifficulty]} coin(s) per correct streak!",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModePicker({required bool isWide}) {
    final tiles =
        modes.map((m) {
          final selected = selectedMode == m;
          return ChoiceChip(
            label: Text(m),
            selected: selected,
            onSelected: (_) => setState(() => selectedMode = m),
            selectedColor: Colors.deepPurple.shade100,
            labelStyle: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          );
        }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🧩 Game Mode",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
              children: tiles,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📘 Game Instructions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "✔️ Tap only the correct numbers according to the selected mode.",
          ),
          Text("   • Prime Finder: tap all primes; avoid composites."),
          Text("   • Composite Catch: tap all composites; avoid primes."),
          Text("   • Twin Prime Rush: tap primes that form (p, p+2) pairs."),
          Text("✔️ You have 60 seconds. Combos and streaks grant bonus coins!"),
          Text("❌ Wrong taps reduce your streak and may deduct marks."),
        ],
      ),
    );
  }

  Widget _buildPreviewChips() {
    final range = difficultyRanges[selectedDifficulty]!;
    final desc = switch (selectedMode) {
      'Prime Finder' => "Identify all primes between ${range[0]}–${range[1]}.",
      'Composite Catch' =>
        "Identify composites; skip primes in ${range[0]}–${range[1]}.",
      'Twin Prime Rush' =>
        "Find twin prime pairs within ${range[0]}–${range[1]}.",
      _ => "",
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        Chip(
          avatar: const Icon(Icons.leaderboard, size: 18),
          label: Text(
            "Points: +${difficultyPoints[selectedDifficulty]} / correct",
          ),
        ),
        Chip(
          avatar: const Icon(Icons.timer, size: 18),
          label: const Text("Time: 60s"),
        ),
        Chip(
          avatar: const Icon(Icons.info_outline, size: 18),
          label: Text(desc, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        if (int.parse(widget.user.dailyTries.toString()) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No tries left. Try again tomorrow.")),
          );
          return;
        }

        final ok = await _confirmDialog();
        if (!ok) return;

        final deducted = await _deductDailyTry();
        if (!deducted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to start. Please try again.")),
          );
          return;
        }

        await _audio.play(AssetSource('sounds/start.mp3'));

        final range = difficultyRanges[selectedDifficulty]!; // e.g. [1, 50]
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => GameGScreen(
                  user: widget.user,
                  difficulty: selectedDifficulty,
                  mode: selectedMode,
                  minValue: range[0],
                  maxValue: range[1],
                ),
          ),
        );

        await _reloadUser();
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  Future<bool> _confirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Start Prime Time?"),
                content: Text(
                  "Use 1 try to play? Tries left: ${widget.user.dailyTries}",
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
      final res = await http.post(
        Uri.parse("https://slumberjer.com/mathwizard/api/update_tries.php"),
        body: {'userid': widget.user.userId},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(() {
            widget.user.dailyTries =
                (int.parse(widget.user.dailyTries.toString()) - 1).toString();
          });
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> _reloadUser() async {
    try {
      final res = await http.post(
        Uri.parse("https://slumberjer.com/mathwizard/api/reload_user.php"),
        body: {'userid': widget.user.userId},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(() {
            widget.user = User.fromJson(data['data']);
          });
        }
      }
    } catch (_) {}
  }
}
