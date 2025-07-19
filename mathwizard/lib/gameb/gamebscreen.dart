// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathwizard/gameb/resultbscreen.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';
import 'package:http/http.dart' as http;

class GameBScreen extends StatefulWidget {
  final User user;
  final String difficulty;

  const GameBScreen({super.key, required this.user, required this.difficulty});

  @override
  _GameBScreenState createState() => _GameBScreenState();
}

class _GameBScreenState extends State<GameBScreen> {
  late Timer timer;
  int timeRemaining = 60;
  int score = 0;
  List<int?> sequence = [];
  List<int?> answersequence = [];
  List<int> missingIndexes = [];
  List<int> answerOptions = [];
  final Random random = Random();
  bool isProcessing = false;
  int comboStreak = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  void _startGame() {
    _generateSequence();
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

  void _generateSequence() {
    int sequenceLength;
    int blanks;

    switch (widget.difficulty) {
      case 'Beginner':
        sequenceLength = 5;
        blanks = 3;
        break;
      case 'Intermediate':
        sequenceLength = 10;
        blanks = 5;
        break;
      case 'Advanced':
        sequenceLength = 15;
        blanks = 8;
        break;
      default:
        sequenceLength = 5;
        blanks = 3;
    }

    int start = random.nextInt(20) + 1;
    int step = random.nextInt(5) + 1;
    bool ascending = random.nextBool();

    sequence = List.generate(
      sequenceLength,
      (index) => ascending ? start + (index * step) : start - (index * step),
    );
    answersequence = List.from(sequence);

    if (sequence.isEmpty) {
      throw Exception("Failed to generate a valid sequence.");
    }

    missingIndexes = [];
    while (missingIndexes.length < blanks) {
      int randomIndex = random.nextInt(sequenceLength);
      if (!missingIndexes.contains(randomIndex)) {
        missingIndexes.add(randomIndex);
      }
    }

    for (int index in missingIndexes) {
      sequence[index] = null;
    }

    answerOptions = List.generate(
      blanks * 2,
      (_) => start + random.nextInt(step * sequenceLength),
    );

    answerOptions.addAll(
      missingIndexes.map(
        (index) => ascending ? start + (index * step) : start - (index * step),
      ),
    );

    answerOptions.shuffle();
  }

  void _handleAnswer(int selectedAnswer, int blankIndex) {
    if (blankIndex < 0 || blankIndex >= sequence.length) {
      throw Exception("Invalid blank index: $blankIndex");
    }

    setState(() {
      int? expectedAnswer = answersequence[blankIndex];

      if (selectedAnswer == expectedAnswer) {
        AudioService.playSfx('sounds/right.wav');
        switch (widget.difficulty) {
          case 'Beginner':
            score += 1;
            break;
          case 'Intermediate':
            score += 2;
            break;
          case 'Advanced':
            score += 3;
            break;
          default:
            score += 1;
        }
        sequence[blankIndex] = selectedAnswer;
        missingIndexes.remove(blankIndex);
        comboStreak++;
        if (comboStreak % 6 == 0) {
          AudioService.playSfx('sounds/coin.wav');
          timeRemaining += 5;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "🎉 Combo x3! +5s bonus time!",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.deepPurpleAccent,
            ),
          );
        }
      } else {
        AudioService.playSfx('sounds/wrong.wav');
        switch (widget.difficulty) {
          case 'Beginner':
            score -= 0;
            break;
          case 'Intermediate':
            score -= 1;
            break;
          case 'Advanced':
            score -= 2;
            break;
          default:
            score -= 1;
        }
      }

      if (missingIndexes.isEmpty) {
        _generateSequence();
      }
    });
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
          'game': 'Sequence Hunter',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + score).toString();
          });
        }
      }
    } finally {
      Navigator.of(context).pop();
      if (score > 0) {
        await AudioService.playSfx('sounds/win.wav');
      } else {
        await AudioService.playSfx('sounds/lose.wav');
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultbScreen(score: score, user: widget.user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    final double baseFontSize = screenWidth * 0.05;
    final double spacing = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sequence Hunter: ${widget.difficulty}",
          style: TextStyle(fontSize: baseFontSize * 0.9),
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Timer and Score Display
                Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "Time: $timeRemaining",
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "⭐ Coins: $score",
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sequence Display
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children:
                          sequence.asMap().entries.map((entry) {
                            final double boxSize = screenWidth * 0.12;
                            return entry.value == null
                                ? SizedBox(
                                  width: boxSize,
                                  height: boxSize,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          spacing * 0.5,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showAnswerOptions(entry.key);
                                    },
                                    child: Text(
                                      "?",
                                      style: TextStyle(
                                        fontSize: baseFontSize * 0.8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                : SizedBox(
                                  width: boxSize,
                                  height: boxSize,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(
                                        spacing * 0.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${entry.value}",
                                        style: TextStyle(
                                          fontSize: baseFontSize * 0.8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                          }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAnswerOptions(int blankIndex) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double baseFontSize = screenWidth * 0.05;
    final double spacing = screenWidth * 0.03;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "Select the Missing Number",
              style: TextStyle(fontSize: baseFontSize * 0.9),
            ),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children:
                    answerOptions.map((option) {
                      return SizedBox(
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                spacing * 0.5,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _handleAnswer(option, blankIndex);
                          },
                          child: FittedBox(
                            child: Text(
                              "$option",
                              style: TextStyle(fontSize: baseFontSize * 0.7),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: baseFontSize * 0.7),
                ),
              ),
            ],
          ),
    );
  }
}
