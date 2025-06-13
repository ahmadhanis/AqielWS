import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:mathwizard/gamea/resultascreen.dart';
import 'package:mathwizard/models/user.dart';

class GameAScreen extends StatefulWidget {
  final String operation;
  final String difficulty; // Difficulty level passed from the selection screen
  final User user;

  GameAScreen({
    required this.operation,
    required this.difficulty,
    required this.user,
  });

  @override
  _GameAScreenState createState() => _GameAScreenState();
}

class _GameAScreenState extends State<GameAScreen> with WidgetsBindingObserver {
  int score = 0;
  int timeRemaining = 60; // in seconds
  late Timer timer;

  String question = "";
  int correctAnswer = 0;
  List<int> answers = [];
  final Random random = Random();
  final Set<String> askedQuestions = {}; // To track already asked questions

  int? wrongAnswerIndex; // Track the wrong answer's index for highlighting
  bool isProcessing = false; // Prevent multiple simultaneous taps

  @override
  void initState() {
    super.initState();

    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Schedule task after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.paused) {
      timer.cancel(); // Pause the timer when the app is minimized
    } else if (state == AppLifecycleState.resumed) {
      // Restart the timer when the app is resumed
      if (timeRemaining > 0) {
        startGame();
      }
    }
  }

  void startGame() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _updateCoin(); // Call the function to update the coins
      }
    });
    generateQuestion();
  }

  Future<void> _updateCoin() async {
    try {
      // Temp solution to bypass SSL certificate error
      HttpClient _createHttpClient() {
        final HttpClient httpClient = HttpClient();
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return httpClient;
      }

      final ioClient = IOClient(_createHttpClient());

      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/update_coin.php",
      );
      final response = await ioClient.post(
        url,
        body: {
          'userid':
              widget.user.userId.toString(), // Assuming user object is passed
          'coin': score.toString(),
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          // Update the user's coin value locally
          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + score).toString();
          });
          print("Coins updated successfully.");
        } else {
          print("Error updating coins: ${responseBody['message']}");
        }
      } else {
        print(
          "Failed to connect to server. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error updating coins: $e");
    } finally {
      // Navigate to ResultScreen
      Navigator.of(context).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultaScreen(
                score: score,
                user: widget.user,
              ), // Pass updated user object
        ),
      );
    }
  }

  void generateQuestion() {
    int a, b, c = 0;
    int digits;
    int answerRange;

    // Determine number of digits and answer range based on difficulty level
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

    do {
      a = random.nextInt(pow(10, digits).toInt()) + 1;
      b = random.nextInt(pow(10, digits).toInt()) + 1;

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
          b = random.nextInt(pow(10, digits).toInt() - 1) + 1; // b >= 1
          a =
              b *
              random.nextInt(pow(10, digits).toInt()); // a is a multiple of b
          question = "$a ÷ $b";
          correctAnswer = a ~/ b;
          break;
      }
    } while (askedQuestions.contains(question));

    askedQuestions.add(question);

    final Set<int> answerSet = {};
    while (answerSet.length < answerRange) {
      int value = correctAnswer + random.nextInt(answerRange * 2) - answerRange;
      answerSet.add(value); // Allow both positive and negative values
    }

    answerSet.remove(answerSet.first);
    answerSet.add(correctAnswer);

    answers = answerSet.toList();
    answers.shuffle();

    wrongAnswerIndex = null;
    isProcessing = false; // Allow new taps
  }

  void handleAnswerTap(int index, int answer) {
    if (isProcessing) return; // Prevent multiple taps
    isProcessing = true;

    setState(() {
      if (answer == correctAnswer) {
        // Correct answer
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
        generateQuestion();
      } else {
        // Wrong answer
        wrongAnswerIndex = index;
        score--;
      }
    });

    // Allow taps again after state is updated
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        wrongAnswerIndex = null;
        isProcessing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solve the following operation"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score and Time Display
            Text(
              question,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Score: $score",
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

            // Answers Section
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

                        return GestureDetector(
                          onTap: () => handleAnswerTap(index, answer),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                isWrongAnswer ? Colors.red : Colors.blue,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "$answer",
                                  style: TextStyle(
                                    fontSize:
                                        24 -
                                        answer.toString().length *
                                            1, // Adjust font size
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
