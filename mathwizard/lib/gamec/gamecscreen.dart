// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathwizard/gamec/resultcscreen.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';
import 'package:http/http.dart' as http;

class GameCScreen extends StatefulWidget {
  final User user;
  final String difficulty;
  final int target;

  const GameCScreen({
    super.key,
    required this.user,
    required this.difficulty,
    required this.target,
  });

  @override
  State<GameCScreen> createState() => _GameCScreenState();
}

class _GameCScreenState extends State<GameCScreen> {
  late List<List<int>> grid;
  List<Offset> path = [];
  int currentSum = 0;
  int gridSize = 4;
  late Timer timer;
  int timeRemaining = 60; // Game duration: 60 seconds
  int score = 0;
  int tries = 0;
  int streak = 0; // Track consecutive wins
  @override
  void initState() {
    super.initState();
    tries = int.parse(widget.user.dailyTries.toString());
    startgame();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startgame() {
    final rand = Random();
    grid = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => rand.nextInt(9) + 1),
    );
    path.clear();
    currentSum = 0;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _updateCoin();
      }
    });
  }

  void _generateGrid() {
    final rand = Random();
    grid = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => rand.nextInt(9) + 1),
    );
    path.clear();
    currentSum = 0;
  }

  bool _isAdjacent(Offset a, Offset b) {
    return (a.dx - b.dx).abs() + (a.dy - b.dy).abs() == 1;
  }

  void _handleTap(int row, int col) {
    Offset tapped = Offset(row.toDouble(), col.toDouble());

    if (path.contains(tapped)) return; // prevent re-tap

    if (path.isEmpty || _isAdjacent(path.last, tapped)) {
      setState(() {
        path.add(tapped);
        currentSum += grid[row][col];
      });

      if (currentSum == widget.target) {
        AudioService.playSfx('sounds/right.wav');
        score = score + _getCoinReward();
        streak++;
        if (streak >= 3) {
          AudioService.playSfx('sounds/coin.wav');
          timeRemaining += 5; // Add 5 seconds for 3 consecutive wins
          streak = 0; // Reset streak
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "🔥Streak Combo! +5 seconds!",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        setState(() {});
        _showResultDialog(true);
      } else if (currentSum > widget.target) {
        if (score > 0) {
          score--; // Deduct 1 coin for wrong answer
          AudioService.playSfx('sounds/wrong.wav');
        }
        streak = 0; // Reset streak
        _showResultDialog(false);
      }
    }
  }

  int _getCoinReward() {
    switch (widget.difficulty) {
      case 'Beginner':
        return 2;
      case 'Intermediate':
        return 3;
      case 'Advanced':
        return 4;
      default:
        return 1;
    }
  }

  void _showResultDialog(bool win) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text(win ? "🎉 You Win!" : "❌ Try Again"),
            content: Text(
              win
                  ? "You reached the target ${widget.target}!"
                  : "Your sum is $currentSum, which is more than ${widget.target}.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _generateGrid();
                  });
                },
                child: const Text("Play Again"),
              ),
              // TextButton(
              //   onPressed: () {
              //     timer.cancel(); // Stop timer
              //     _updateCoin(); // Update coins before exiting
              //   },
              //   child: const Text("Exit"),
              // ),
            ],
          ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridSize * gridSize,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        int row = index ~/ gridSize;
        int col = index % gridSize;
        final isSelected = path.contains(
          Offset(row.toDouble(), col.toDouble()),
        );

        return GestureDetector(
          onTap: () => _handleTap(row, col),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.greenAccent : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueGrey),
            ),
            child: Text(
              grid[row][col].toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Math Maze"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ), // Limit width on large screens
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time, Score & Streak
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Time: $timeRemaining",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "⭐ Coins: $score",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Streak: $streak",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Target
                  Text(
                    "🎯 Target: ${widget.target}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Current Sum: $currentSum",
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildGrid(); // You can adapt grid layout here too
                    },
                  ),

                  const SizedBox(height: 20),

                  // Reset Button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _generateGrid();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      "Reset Grid",
                      style: TextStyle(fontFamily: 'ComicSans'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to update coins: ${responseBody['message']}",
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } finally {
      if (score > 0) {
        AudioService.playSfx('sounds/win.wav');
      } else {
        AudioService.playSfx('sounds/lose.wav');
      }
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultcScreen(
                score: score,
                user: widget.user,
                target: widget.target,
              ),
        ),
      );
    }
  }
}
