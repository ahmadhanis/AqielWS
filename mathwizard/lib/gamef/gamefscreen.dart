// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/gamef/resultfscreen.dart';
import 'package:mathwizard/models/user.dart';

class GameFScreen extends StatefulWidget {
  final User user;
  final String difficulty;

  const GameFScreen({super.key, required this.user, required this.difficulty});

  @override
  State<GameFScreen> createState() => _GameFScreenState();
}

class _GameFScreenState extends State<GameFScreen> {
  late Timer timer;
  int timeRemaining = 60;
  int score = 0;
  int streak = 0;
  int pyramidCount = 0;
  final AudioPlayer audioPlayer = AudioPlayer();
  final Random random = Random();
  late int screenHeight, screenWidth;
  List<List<int?>> pyramid = [];
  List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    _setDifficultyParameters();
    _generateNewPyramid();
    _startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    audioPlayer.dispose();
    super.dispose();
  }

  void _setDifficultyParameters() {
    switch (widget.difficulty) {
      case 'Intermediate':
        timeRemaining = 75;
        break;
      case 'Advanced':
        timeRemaining = 90;
        break;
      default:
        timeRemaining = 60;
    }
  }

  void _startTimer() {
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

  void _generateNewPyramid() {
    pyramid.clear();
    controllers.clear();
    int min = 1, max = 10;
    int baseSize = 3;

    // Adjust pyramid size and number range based on difficulty and progress
    switch (widget.difficulty) {
      case 'Intermediate':
        min = 5;
        max = 25;
        baseSize = pyramidCount < 5 ? 3 : 4;
        break;
      case 'Advanced':
        min = -30;
        max = 60;
        baseSize =
            pyramidCount < 3
                ? 3
                : pyramidCount < 6
                ? 4
                : 5;
        break;
    }

    // Generate base row
    List<int> base = List.generate(
      baseSize,
      (_) => random.nextInt(max - min + 1) + min,
    );

    // Build pyramid upwards
    pyramid = [base];
    for (int i = baseSize - 1; i > 0; i--) {
      List<int> nextRow = [];
      for (int j = 0; j < i; j++) {
        nextRow.add(pyramid.last[j]! + pyramid.last[j + 1]!);
      }
      pyramid.add(nextRow);
    }
    pyramid = pyramid.reversed.toList();

    // Ensure at least one non-null value per row to avoid invalid pyramids
    int blanks =
        widget.difficulty == 'Beginner'
            ? baseSize
            : widget.difficulty == 'Intermediate'
            ? baseSize + 1
            : baseSize + 2;
    int placedBlanks = 0;
    Set<String> blankedPositions = {};

    while (placedBlanks < blanks) {
      int row = random.nextInt(pyramid.length);
      int col = random.nextInt(pyramid[row].length);
      String pos = '$row-$col';

      if (pyramid[row][col] != null && !blankedPositions.contains(pos)) {
        // Ensure row doesn't become entirely null
        int nonNullCount = pyramid[row].where((val) => val != null).length;
        if (nonNullCount > 1) {
          // Keep at least one non-null value per row
          pyramid[row][col] = null;
          blankedPositions.add(pos);
          placedBlanks++;
        }
      }
    }

    // Populate controllers
    for (var row in pyramid) {
      for (var val in row) {
        controllers.add(TextEditingController(text: val?.toString() ?? ""));
      }
    }
  }

  Widget _buildPyramid() {
    int i = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          pyramid.asMap().entries.map((entry) {
            int rowIndex = entry.key;
            var row = entry.value;
            double offset = (pyramid.length - rowIndex - 1) * 30.0;
            return Padding(
              padding: EdgeInsets.only(left: offset, right: offset),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    row.asMap().entries.map((cell) {
                      int colIndex = cell.key;
                      final index = i;
                      final controller = controllers[i++];
                      return GestureDetector(
                        onTap: () {
                          if (pyramid[rowIndex][colIndex] == null) {
                            _showNumberPicker(index, rowIndex, colIndex);
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 50,
                          margin: const EdgeInsets.all(6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                pyramid[rowIndex][colIndex] == null
                                    ? Colors.white
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  pyramid[rowIndex][colIndex] == null
                                      ? Colors.blue
                                      : Colors.grey,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            controller.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  void _showNumberPicker(int index, int row, int col) {
    int min = widget.difficulty == 'Advanced' ? -30 : 1;
    int max =
        widget.difficulty == 'Advanced'
            ? 60
            : widget.difficulty == 'Intermediate'
            ? 25
            : 10;
    List<int> numberOptions = List.generate(max - min + 1, (i) => min + i);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Select a number"),
            content: SizedBox(
              width: double.maxFinite,
              height: screenHeight * 0.4,
              child: GridView.count(
                crossAxisCount: 5,
                childAspectRatio: 1.5,
                children:
                    numberOptions.map((num) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            controllers[index].text = num.toString();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: Text(
                            num.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  void _checkAnswer() {
    try {
      int i = 0;
      List<List<int?>> userPyramid =
          pyramid.map((row) {
            return row.map((val) {
              final text = controllers[i++].text;
              if (text.isEmpty && val == null) {
                throw Exception("Please complete all blanks.");
              }
              final parsed = int.tryParse(text);
              if (parsed == null && val == null) {
                throw Exception("Invalid number entered in a blank cell.");
              }
              return parsed ?? val; // Use original value if not a blank
            }).toList();
          }).toList();

      bool valid = true;
      for (int row = 0; row < pyramid.length - 1; row++) {
        for (
          int col = 0;
          col < pyramid[row].length && col + 1 < pyramid[row + 1].length;
          col++
        ) {
          if (userPyramid[row][col] != null &&
              userPyramid[row + 1][col] != null &&
              userPyramid[row + 1][col + 1] != null) {
            valid &=
                userPyramid[row][col] ==
                userPyramid[row + 1][col]! + userPyramid[row + 1][col + 1]!;
          } else {
            valid = false; // Invalidate if required values are missing
          }
        }
      }

      if (valid) {
        pyramidCount++;
        streak++;
        score += _getScorePerPyramid();
        audioPlayer.play(AssetSource('sounds/win.wav'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Correct! Streak: $streak"),
            backgroundColor: Colors.green,
          ),
        );
        _generateNewPyramid();
        if (widget.difficulty != 'Beginner' && pyramidCount % 3 == 0) {
          timeRemaining += 10; // Bonus time for progress
        }
        setState(() {});
      } else {
        streak = 0;
        audioPlayer.play(AssetSource('sounds/wrong.wav'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Wrong pyramid structure."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      audioPlayer.play(AssetSource('sounds/wrong.wav'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  int _getScorePerPyramid() {
    int baseScore =
        widget.difficulty == 'Intermediate'
            ? 4
            : widget.difficulty == 'Advanced'
            ? 8
            : 2;
    return baseScore + (streak ~/ 3); // Bonus for streaks
  }

  Future<void> _updateCoin() async {
    try {
      final response = await http.post(
        Uri.parse("https://slumberjer.com/mathwizard/api/update_coin.php"),
        body: {
          'userid': widget.user.userId.toString(),
          'coin': score.toString(),
        },
      );
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['status'] == 'success') {
          widget.user.coin =
              (int.parse(widget.user.coin.toString()) + score).toString();
        }
      }
    } catch (e) {
      // Optional error handling
    } finally {
      audioPlayer.play(
        AssetSource(score > 0 ? 'sounds/win.wav' : 'sounds/lose.wav'),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultfScreen(score: score, user: widget.user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height.toInt();
    screenWidth = MediaQuery.of(context).size.width.toInt();
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: Text("${widget.difficulty} Pyramid Challenge"),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
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
                  "Time: $timeRemaining",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Streak: $streak",
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Expanded(child: Center(child: _buildPyramid())),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _checkAnswer,
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
