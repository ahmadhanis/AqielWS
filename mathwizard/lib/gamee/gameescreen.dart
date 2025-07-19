// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/gamee/resultescreen.dart';
import 'package:mathwizard/models/audioservice.dart';
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
        AudioService.playSfx('sounds/right.wav');
        score += _getCoinReward();
        comboStreak++;
        flashGreenIndex = selectedIndex;

        if (comboStreak % 5 == 0) {
          timeRemaining += 5;
          AudioService.playSfx('sounds/coin.wav');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "🔥 5-Streak! +5s Bonus!",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } else {
        AudioService.playSfx('sounds/wrong.wav');
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double baseFontSize = screenWidth > 900 ? 18 : screenWidth * 0.045;
    final double spacing = screenWidth > 900 ? 16 : screenWidth * 0.03;
    final double optionWidth = screenWidth > 900 ? 150 : screenWidth * 0.35;
    final double optionHeight = screenWidth > 900 ? 60 : screenHeight * 0.08;
    // final int crossAxisCount = screenWidth > 900 ? 4 : 2; // More columns on desktop

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "🏃‍♂️ Math Runner",
          style: TextStyle(fontSize: baseFontSize * 1.1),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: baseFontSize),
          onPressed: () {
            timer.cancel();
            _updateCoin();
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(spacing),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "⏱ Time: $timeRemaining",
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "⭐ Score: $score",
                          style: TextStyle(
                            fontSize: baseFontSize,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing),
                    child: Text(
                      "🔥 Streak: $comboStreak",
                      style: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  Text(
                    "🎯 Reach: $target",
                    style: TextStyle(
                      fontSize: baseFontSize * 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing * 3),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          screenHeight * 0.4, // Limit height for scrolling
                      minHeight: optionHeight * 2 + spacing,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        alignment: WrapAlignment.center,
                        children: List.generate(options.length, (index) {
                          final opt = options[index];
                          final isRed = flashRedIndices.contains(index);
                          final isGreen = flashGreenIndex == index;
                          bool isHovered = false;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return MouseRegion(
                                onEnter:
                                    (_) => setState(() => isHovered = true),
                                onExit:
                                    (_) => setState(() => isHovered = false),
                                child: GestureDetector(
                                  onTap: () => _handleChoice(opt),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: optionWidth,
                                    height: optionHeight,
                                    padding: EdgeInsets.all(spacing * 0.5),
                                    decoration: BoxDecoration(
                                      color:
                                          isGreen
                                              ? Colors.greenAccent
                                              : (isRed
                                                  ? Colors.redAccent
                                                  : Colors.blueAccent),
                                      borderRadius: BorderRadius.circular(
                                        spacing,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isHovered ? 0.3 : 0.2,
                                          ),
                                          blurRadius: spacing * 0.5,
                                          offset: Offset(0, spacing * 0.2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        child: Text(
                                          opt,
                                          style: TextStyle(
                                            fontSize: baseFontSize * 0.9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  Text(
                    "Gate ${questionIndex + 1}",
                    style: TextStyle(
                      fontSize: baseFontSize * 0.8,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          'game': 'Math Runner',
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
        AudioService.playSfx('sounds/win.wav');
      } else {
        AudioService.playSfx('sounds/lose.wav');
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
