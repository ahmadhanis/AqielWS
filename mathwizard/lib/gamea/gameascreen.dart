// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mathwizard/gamea/resultascreen.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';

class GameAScreen extends StatefulWidget {
  final String operation;
  final String difficulty;
  final User user;

  const GameAScreen({
    super.key,
    required this.operation,
    required this.difficulty,
    required this.user,
  });

  @override
  _GameAScreenState createState() => _GameAScreenState();
}

class _GameAScreenState extends State<GameAScreen> with WidgetsBindingObserver {
  int score = 0;
  int timeRemaining = 60;
  int streak = 0;
  late Timer timer;
  String question = "";
  int correctAnswer = 0;
  List<int> answers = [];
  final Random random = Random();
  final Set<String> askedQuestions = {};

  int? wrongAnswerIndex;
  int? correctAnswerIndex;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      timer.cancel();
    } else if (state == AppLifecycleState.resumed && timeRemaining > 0) {
      if (!timer.isActive) {
        startGame();
      }
    }
  }

  void startGame() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _updateCoin();
      }
    });
    generateQuestion();
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
          'game': 'Quik Math',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + score).toString();
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultaScreen(score: score, user: widget.user),
        ),
      );
    }
  }

  void generateQuestion() {
    int a, b, c = 0;
    int digits;
    int answerRange;

    switch (widget.difficulty) {
      case 'Beginner':
        digits = 1;
        answerRange = 10;
        break;
      case 'Intermediate':
        digits = 2;
        answerRange = 15;
        break;
      case 'Advanced':
        digits = 3;
        answerRange = 10;
        break;
      default:
        digits = 1;
        answerRange = 10;
    }
    int attempt = 0;
    do {
      a = random.nextInt(pow(10, digits).toInt()) + 1;
      b = random.nextInt(pow(10, digits).toInt()) + 1;
      attempt++;
      if (widget.difficulty == 'Advanced') {
        c = random.nextInt(pow(10, digits - 1).toInt()) + 1;
      }
      switch (widget.operation) {
        case '+':
          question =
              widget.difficulty == 'Advanced' ? "$a + $b + $c" : "$a + $b";
          correctAnswer = widget.difficulty == 'Advanced' ? a + b + c : a + b;
          break;
        case '-':
          if (a < b) {
            int temp = a;
            a = b;
            b = temp;
          }
          question =
              widget.difficulty == 'Advanced' ? "$a - $b - $c" : "$a - $b";
          correctAnswer = widget.difficulty == 'Advanced' ? a - b - c : a - b;
          break;
        case '×':
          question =
              widget.difficulty == 'Advanced' ? "$a × $b × $c" : "$a × $b";
          correctAnswer = widget.difficulty == 'Advanced' ? a * b * c : a * b;
          break;
        case '÷':
          b = random.nextInt(pow(10, digits).toInt() - 1) + 1;
          a = b * random.nextInt(pow(10, digits).toInt());
          question = "$a ÷ $b";
          correctAnswer = a ~/ b;
          break;
      }
      if (attempt > 50) break;
    } while (askedQuestions.contains(question));

    askedQuestions.add(question);

    final Set<int> answerSet = {};
    while (answerSet.length < answerRange) {
      int value = correctAnswer + random.nextInt(answerRange * 2) - answerRange;
      answerSet.add(value);
    }

    answerSet.remove(answerSet.first);
    answerSet.add(correctAnswer);

    setState(() {
      answers = answerSet.toList()..shuffle();
      wrongAnswerIndex = null;
      correctAnswerIndex = null;
      isProcessing = false;
    });
  }

  void handleAnswerTap(int index, int answer) {
    if (isProcessing) return;
    isProcessing = true;

    setState(() {
      if (answer == correctAnswer) {
        correctAnswerIndex = index; // Highlight correct answer in green
        streak++;
        AudioService.playSfx('sounds/right.wav');

        if (streak >= 5) {
          AudioService.playSfx('sounds/coin.wav');
          timeRemaining += 2;
          streak = 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "🔥 5-Streak! +2s Bonus!",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.orangeAccent,
            ),
          );
          AudioService.playSfx('sounds/coin.wav');
        }
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
        }
        AudioService.playSfx('sounds/right.wav');
        generateQuestion();
      } else {
        AudioService.playSfx('sounds/wrong.wav');
        streak = 0;
        wrongAnswerIndex = index;
        if (score > 0) {
          score--;
        }
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        wrongAnswerIndex = null;
        correctAnswerIndex = null;
        isProcessing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solve"),
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
      body: SafeArea(
        child: Column(
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "⭐ Coins: $score",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "Time: $timeRemaining",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
              ),
            ),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 20.0,
                  runSpacing: 20.0,
                  children:
                      answers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;
                        final isWrongAnswer = wrongAnswerIndex == index;
                        final isCorrectAnswer = correctAnswerIndex == index;

                        return GestureDetector(
                          onTap: () => handleAnswerTap(index, answer),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                isCorrectAnswer
                                    ? Colors.greenAccent
                                    : (isWrongAnswer
                                        ? Colors.red
                                        : (isProcessing
                                            ? Colors.grey
                                            : Colors.blue)),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "$answer",
                                  style: TextStyle(
                                    fontSize: 24 - answer.toString().length * 1,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
