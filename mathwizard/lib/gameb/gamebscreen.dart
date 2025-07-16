// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mathwizard/gameb/resultbscreen.dart';
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
  int timeRemaining = 60; // Game duration: 60 seconds
  int score = 0;
  List<int?> sequence = [];
  List<int?> answersequence = [];
  List<int> missingIndexes = [];
  List<int> answerOptions = [];
  final Random random = Random();
  bool isProcessing = false; // To prevent multiple simultaneous taps
  int comboStreak = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    timer.cancel();
    _audioPlayer.dispose();
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

    // Determine the sequence length and number of blanks based on difficulty
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

    // Generate a sorted sequence in ascending or descending order
    int start = random.nextInt(20) + 1; // Random start point
    int step = random.nextInt(5) + 1; // Random step size
    bool ascending = random.nextBool(); // Random order

    sequence = List.generate(
      sequenceLength,
      (index) => ascending ? start + (index * step) : start - (index * step),
    );
    answersequence = List.from(sequence);

    // Ensure sequence is not empty
    if (sequence.isEmpty) {
      throw Exception("Failed to generate a valid sequence.");
    }

    // Select random indices to replace with blanks
    missingIndexes = [];
    while (missingIndexes.length < blanks) {
      int randomIndex = random.nextInt(sequenceLength);
      if (!missingIndexes.contains(randomIndex)) {
        missingIndexes.add(randomIndex);
      }
    }

    // Replace the selected indices with `null` (blanks)
    for (int index in missingIndexes) {
      sequence[index] = null;
    }

    // Generate answer options
    answerOptions = List.generate(
      blanks * 2,
      (_) => start + random.nextInt(step * sequenceLength),
    );

    // Add the correct answers
    answerOptions.addAll(
      missingIndexes.map(
        (index) => ascending ? start + (index * step) : start - (index * step),
      ),
    );

    // Shuffle the answer options
    answerOptions.shuffle();
  }

  void _handleAnswer(int selectedAnswer, int blankIndex) {
    // print("SELECTED ANSWER: $selectedAnswer, BLANK INDEX: $blankIndex");
    if (blankIndex < 0 || blankIndex >= sequence.length) {
      throw Exception("Invalid blank index: $blankIndex");
    }

    setState(() {
      int? expectedAnswer = answersequence[blankIndex];

      if (selectedAnswer == expectedAnswer) {
        // Correct answer
        _audioPlayer.play(AssetSource('sounds/right.wav'));
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
            score += 1; // Default to beginner if difficulty is unknown
        }
        sequence[blankIndex] = selectedAnswer; // Fill the blank in the sequence
        missingIndexes.remove(blankIndex); // Remove from missing indexes
        comboStreak++;
        if (comboStreak % 6 == 0) {
          _audioPlayer.play(AssetSource('sounds/coin.wav'));
          timeRemaining += 5;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Combo x3! +5s bonus time!"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.deepPurpleAccent,
            ),
          );
        }
      } else {
        _audioPlayer.play(AssetSource('sounds/wrong.wav'));
        // Incorrect answer
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
            score -= 1; // Default to beginner if difficulty is unknown
        }
      }

      // Check if all blanks are filled
      if (missingIndexes.isEmpty) {
        _generateSequence(); // Generate a new sequence
      }
    });
  }

  // Future<void> _updateCoin() async {
  //   try {
  //     // Temp solution to bypass SSL certificate error
  //     HttpClient createHttpClient() {
  //       final HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //       return httpClient;
  //     }

  //     final ioClient = IOClient(createHttpClient());

  //     final url = Uri.parse(
  //       "https://slumberjer.com/mathwizard/api/update_coin.php",
  //     );
  //     final response = await ioClient.post(
  //       url,
  //       body: {
  //         'userid':
  //             widget.user.userId.toString(), // Assuming user object is passed
  //         'coin': score.toString(),
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);

  //       if (responseBody['status'] == 'success') {
  //         // Update the user's coin value locally
  //         setState(() {
  //           widget.user.coin =
  //               (int.parse(widget.user.coin.toString()) + score).toString();
  //         });
  //       } else {}
  //     } else {}
  //   } catch (e) {
  //   } finally {
  //     // Navigate to ResultScreen
  //     Navigator.of(context).pop();
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (_) => ResultbScreen(
  //               score: score,
  //               user: widget.user,
  //             ), // Pass updated user object
  //       ),
  //     );
  //   }
  // }

  Future<void> _updateCoin() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/update_coin.php", // Use HTTP
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
          // Update the user's coin value locally

          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + score).toString();
          });
        } else {}
      } else {}
    } finally {
      // Navigate to ResultScreen
      Navigator.of(context).pop();
      if (score > 0) {
        await _audioPlayer.play(AssetSource('sounds/win.wav'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/lose.wav'));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Sequence Hunter: ${widget.difficulty}"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer and Score Display
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Time: $timeRemaining",
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                  Text(
                    "Score: $score",
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                ],
              ),
            ),

            // Sequence Display
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      sequence
                          .asMap()
                          .entries
                          .map(
                            (entry) =>
                                entry.value == null
                                    ? SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Show answer options for this blank
                                          _showAnswerOptions(entry.key);
                                        },
                                        child: const Text(
                                          "?",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    : SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${entry.value}",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                          )
                          .toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAnswerOptions(int blankIndex) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Select the Missing Number"),
            content: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  answerOptions
                      .map(
                        (option) => ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _handleAnswer(option, blankIndex);
                          },
                          child: Text("$option"),
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }
}
