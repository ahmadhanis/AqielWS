// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';
import 'package:mathwizard/gamed/resultdscreen.dart'; // Updated import

class GameDScreen extends StatefulWidget {
  final User user;
  final String difficulty;
  final int target;

  const GameDScreen({
    super.key,
    required this.user,
    required this.difficulty,
    required this.target,
  });

  @override
  State<GameDScreen> createState() => _GameDScreenState();
}

class _GameDScreenState extends State<GameDScreen> {
  List<String> availableTiles = [];
  List<String> droppedTiles = ["", "", ""];
  late Timer timer;
  int timeRemaining = 60;
  int score = 0;
  int tries = 0;

  @override
  void initState() {
    super.initState();
    tries = int.parse(widget.user.dailyTries.toString());
    generateTiles();
    startTimer();
  }

  void generateTiles() {
    final rand = Random();
    List<String> numbers = List.generate(
      5,
      (_) => (rand.nextInt(20) + 1).toString(),
    );
    List<String> operators = ['+', '-', '×', '÷'];
    availableTiles = [...numbers, ...operators]..shuffle();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() => timeRemaining--);
      } else {
        timer.cancel();
        _updateCoin();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  bool evaluateEquation() {
    try {
      final num1 = int.parse(droppedTiles[0]);
      final op = droppedTiles[1];
      final num2 = int.parse(droppedTiles[2]);
      double result;

      switch (op) {
        case '+':
          result = num1 + num2.toDouble();
          break;
        case '-':
          result = num1 - num2.toDouble();
          break;
        case '×':
          result = num1 * num2.toDouble();
          break;
        case '÷':
          if (num2 == 0) return false;
          result = num1 / num2;
          break;
        default:
          return false;
      }

      return result == widget.target;
    } catch (e) {
      return false;
    }
  }

  int _getCoinReward() {
    switch (widget.difficulty) {
      case 'Beginner':
        return 2;
      case 'Intermediate':
        return 4;
      case 'Advanced':
        return 6;
      default:
        return 2;
    }
  }

  void _checkAnswer() {
    if (droppedTiles.contains("")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete the equation.")),
      );
      return;
    }

    final win = evaluateEquation();

    if (win) {
      AudioService.playSfx('sounds/win.wav');
      score += _getCoinReward();
      _showResultDialog(true);
    } else {
      AudioService.playSfx('sounds/wrong.wav');
      _showResultDialog(false);
    }
  }

  void _showResultDialog(bool win) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text(win ? "🎉 Correct!" : "❌ Wrong Answer"),
            content: Text(
              win
                  ? "You solved the equation!"
                  : "Try again or rearrange your equation.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    droppedTiles = ["", "", ""];
                    generateTiles();
                  });
                },
                child: const Text("Try Another"),
              ),
              // TextButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: const Text("Close"),
              // ),
            ],
          ),
    );
  }

  Widget _buildDraggableTile(String value) {
    return Draggable<String>(
      data: value,
      feedback: Material(child: _tile(value, Colors.amber)),
      childWhenDragging: _tile(value, Colors.grey),
      child: _tile(value, Colors.blueAccent),
    );
  }

  Widget _tile(String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }

  Widget _buildDropTarget(int index) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 70,
          height: 60,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                droppedTiles[index].isEmpty
                    ? Colors.grey[300]
                    : Colors.green[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              droppedTiles[index],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
      onAcceptWithDetails: (details) {
        setState(() {
          droppedTiles[index] = details.data;
          availableTiles.remove(details.data);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Equation Builder"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            timer.cancel();
            _updateCoin();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "⏱ Time: $timeRemaining",
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
                Text(
                  "⭐ Score: $score",
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "🎯 Target: ${widget.target}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Build a valid equation:"),
            const SizedBox(height: 16),

            // Equation slots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropTarget(0),
                const SizedBox(width: 8),
                _buildDropTarget(1),
                const SizedBox(width: 8),
                _buildDropTarget(2),
                const SizedBox(width: 8),
                const Text("=", style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text("${widget.target}", style: const TextStyle(fontSize: 24)),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text("Check Answer"),
            ),

            const SizedBox(height: 20),

            // Draggable tiles
            Wrap(
              alignment: WrapAlignment.center,
              children:
                  availableTiles
                      .map((value) => _buildDraggableTile(value))
                      .toList(),
            ),
            ElevatedButton(
              onPressed: () {
                generateTiles();
              },
              child: const Text("Reset Tiles"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCoin() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/update_coin.php",
      );

      final response = await http.post(
        url,
        body: {
          'userid': widget.user.userId.toString(),
          'coin': score.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + score).toString();
            widget.user.dailyTries = tries.toString();
          });
        }
      }
    } finally {
      if (score > 0) {
        AudioService.playSfx('sounds/win.wav');
      } else {
        AudioService.playSfx('sounds/lose.wav');
      }
      // Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultdScreen(
                score: score,
                user: widget.user,
                target: widget.target,
              ),
        ),
      );
    }
  }
}
