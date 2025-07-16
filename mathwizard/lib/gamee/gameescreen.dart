// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/gamee/resultescreen.dart';
import 'package:mathwizard/models/user.dart';

class GameEScreen extends StatefulWidget {
  final User user;
  final String difficulty;

  const GameEScreen({super.key, required this.user, required this.difficulty});

  @override
  State<GameEScreen> createState() => _GameEScreenState();
}

class _GameEScreenState extends State<GameEScreen> {
  late Timer timer;
  int timeRemaining = 60;
  int score = 0;
  int questionIndex = 0;
  late String correctAnswer;
  late List<String> options;
  late String target;
  List<int> flashRedIndices = [];
  int? flashGreenIndex;
  int comboStreak = 0;
  final AudioPlayer audioPlayer = AudioPlayer();
  final rand = Random();

  @override
  void initState() {
    super.initState();
    _generateGate();
    _startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() => timeRemaining--);
      } else {
        timer.cancel();
        _updateCoin();
      }
    });
  }

  void _generateGate() {
    final ops =
        {
          'Beginner': ['+', '-'],
          'Intermediate': ['+', '-', '×'],
          'Advanced': ['+', '-', '×', '÷'],
        }[widget.difficulty]!;

    final maxRange =
        {'Beginner': 10, 'Intermediate': 20, 'Advanced': 50}[widget
            .difficulty]!;

    String op = ops[rand.nextInt(ops.length)];

    int a, b, result;

    if (op == '÷') {
      b = rand.nextInt(9) + 1;
      result = rand.nextInt(6) + 1;
      a = b * result;
    } else {
      a = rand.nextInt(maxRange) + 1;
      b = rand.nextInt(maxRange) + 1;

      result = switch (op) {
        '+' => a + b,
        '-' => a - b,
        '×' => a * b,
        _ => a + b,
      };
    }

    correctAnswer = "$a $op $b";
    target = "$result";

    Set<String> generated = {correctAnswer};

    while (generated.length < 4) {
      String wrongOp = ops[rand.nextInt(ops.length)];

      int wrongA = rand.nextInt(maxRange) + 1;
      int wrongB = rand.nextInt(maxRange) + 1;
      String expr;

      if (wrongOp == '÷') {
        wrongB = rand.nextInt(9) + 1;
        int wrongRes = rand.nextInt(6) + 1;
        wrongA = wrongB * wrongRes;
        expr = "$wrongA ÷ $wrongB";
      } else {
        expr = "$wrongA $wrongOp $wrongB";
      }

      try {
        double eval = _evaluateExpression(wrongA, wrongOp, wrongB);
        if (eval.toString() != target && eval.isFinite) {
          generated.add(expr);
        }
      } catch (_) {
        // skip if invalid
      }
    }

    options = generated.toList()..shuffle();
  }

  double _evaluateExpression(int a, String op, int b) {
    return switch (op) {
      '+' => a + b.toDouble(),
      '-' => a - b.toDouble(),
      '×' => a * b.toDouble(),
      '÷' => b == 0 ? double.nan : a / b,
      _ => double.nan,
    };
  }

  void _handleChoice(String chosen) {
    final isCorrect = chosen == correctAnswer;
    final selectedIndex = options.indexOf(chosen);

    setState(() {
      if (isCorrect) {
        audioPlayer.play(AssetSource('sounds/right.wav'));
        score += _getCoinReward();
        comboStreak++;
        flashGreenIndex = selectedIndex; // Highlight correct choice in green

        if (comboStreak % 5 == 0) {
          timeRemaining += 5;
          audioPlayer.play(AssetSource('sounds/coin.wav'));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🔥 5-Streak! +5s Bonus!"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } else {
        audioPlayer.play(AssetSource('sounds/wrong.wav'));
        score -= _getPenalty();
        if (score < 0) score = 0;
        comboStreak = 0;
        flashRedIndices.add(selectedIndex);
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        flashRedIndices.clear();
        flashGreenIndex = null;
        questionIndex++;
        _generateGate();
      });
    });
  }

  int _getPenalty() {
    switch (widget.difficulty) {
      case 'Beginner':
        return 1;
      case 'Intermediate':
        return 1;
      case 'Advanced':
        return 2;
      default:
        return 1;
    }
  }

  int _getCoinReward() {
    switch (widget.difficulty) {
      case 'Beginner':
        return 1;
      case 'Intermediate':
        return 2;
      case 'Advanced':
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("🏃‍♂️ Math Runner"),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "🔥 Streak: $comboStreak",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "🎯 Reach: $target",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(options.length, (index) {
                  final opt = options[index];
                  final isRed = flashRedIndices.contains(index);
                  final isGreen = flashGreenIndex == index;

                  return GestureDetector(
                    onTap: () => _handleChoice(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isGreen
                                ? Colors.greenAccent
                                : (isRed
                                    ? Colors.redAccent
                                    : Colors.blueAccent),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          opt,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Gate ${questionIndex + 1}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCoin() async {
    try {
      final url = Uri.parse(
        "http://slumberjer.com/mathwizard/api/update_coin.php",
      );

      final response = await http.post(
        url,
        body: {
          'userid': widget.user.userId.toString(),
          'coin': score.toString(),
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + score).toString();
          });
        }
      }
    } catch (e) {
      // handle error silently
    } finally {
      if (score > 0) {
        audioPlayer.play(AssetSource('sounds/win.wav'));
      } else {
        audioPlayer.play(AssetSource('sounds/lose.wav'));
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResulteScreen(user: widget.user, score: score),
        ),
      );
    }
  }
}
