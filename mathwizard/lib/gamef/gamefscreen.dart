// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathwizard/gamef/resultfscreen.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';
import 'package:http/http.dart' as http;

class GameFScreen extends StatefulWidget {
  final User user;
  final String difficulty;

  const GameFScreen({super.key, required this.user, required this.difficulty});

  @override
  State<GameFScreen> createState() => _GameFScreenState();
}

class _GameFScreenState extends State<GameFScreen> {
  late Timer _timer;
  int _streak = 0; // New variable to track streak
  int _remainingTime = 60;
  int _score = 0;
  late int _levels;
  late int _numBlanks;
  late int _maxRange;
  late int _pointsPer;

  late List<List<int>> _fullPyramid;
  late List<List<String?>> _pyramidDisplay;
  late List<Offset> _blankPositions;
  late Map<Offset, List<int>> _optionsPerBlank;

  @override
  void initState() {
    super.initState();
    _configureDifficulty();
    _generateNewPuzzle();
    _startTimer();
  }

  void _configureDifficulty() {
    final rand = Random();
    switch (widget.difficulty) {
      case 'Intermediate':
        _levels = 4;
        _numBlanks = 4;
        _maxRange = 50;
        _pointsPer = 2;
        break;
      case 'Advanced':
        _levels = 5;
        _numBlanks = rand.nextInt(3) + 6; // 6 to 8 blanks
        _maxRange = 99;
        _pointsPer = 3;
        break;
      default:
        _levels = 3;
        _numBlanks = 2;
        _maxRange = 20;
        _pointsPer = 1;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        _endGame();
      }
    });
  }

  void _generateNewPuzzle() {
    final rand = Random();
    // Build bottom-up pyramid
    List<List<int>> pyramid = [];
    List<int> bottom = List.generate(
      _levels,
      (_) => rand.nextInt(_maxRange) + 1,
    );
    pyramid.add(bottom);
    for (int r = 1; r < _levels; r++) {
      final prev = pyramid[r - 1];
      List<int> curr = [];
      for (int i = 0; i < prev.length - 1; i++) {
        curr.add(prev[i] + prev[i + 1]);
      }
      pyramid.add(curr);
    }
    // Top-down order for display
    _fullPyramid = pyramid.reversed.toList();

    // Initialize display and blanks
    _pyramidDisplay = List.generate(
      _levels,
      (r) => List<String?>.generate(
        _fullPyramid[r].length,
        (c) => _fullPyramid[r][c].toString(),
      ),
    );
    _blankPositions = [];
    _optionsPerBlank = {};
    while (_blankPositions.length < _numBlanks) {
      int r = rand.nextInt(_levels);
      int c = rand.nextInt(_fullPyramid[r].length);
      final pos = Offset(r.toDouble(), c.toDouble());
      if (!_blankPositions.contains(pos)) {
        _blankPositions.add(pos);
        _pyramidDisplay[r][c] = null;
        // Generate options: correct + 9 wrong (total 10 options)
        int correct = _fullPyramid[r][c];
        Set<int> opts = {correct};
        while (opts.length < 10) {
          int wrong = rand.nextInt(_maxRange * 2) + 1;
          if (wrong != correct) opts.add(wrong);
        }
        final list = opts.toList()..shuffle();
        _optionsPerBlank[pos] = list;
      }
    }
    setState(() {});
  }

  void _showOptionsDialog(int r, int c, double cellSize, double fontSize) {
    final pos = Offset(r.toDouble(), c.toDouble());
    final options = _optionsPerBlank[pos]!;
    final double dialogFont = fontSize * 0.7; // Smaller font for more options
    final double dialogSpacing = cellSize * 0.1; // Tighter spacing
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Choose the correct number',
            style: TextStyle(fontSize: dialogFont),
          ),
          content: SizedBox(
            width: cellSize * 3, // Wider dialog to accommodate more options
            child: Wrap(
              spacing: dialogSpacing,
              runSpacing: dialogSpacing,
              alignment: WrapAlignment.center,
              children:
                  options.map((val) {
                    return SizedBox(
                      width: cellSize * 0.8, // Smaller buttons for 10 options
                      height: cellSize * 0.5,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _pyramidDisplay[r][c] = val.toString();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          val.toString(),
                          style: TextStyle(fontSize: dialogFont * 0.9),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    int correct = 0;
    for (final pos in _blankPositions) {
      final r = pos.dx.toInt();
      final c = pos.dy.toInt();
      final expected = _fullPyramid[r][c];
      final input = int.tryParse(_pyramidDisplay[r][c] ?? '') ?? -999999;
      if (input == expected) correct++;
    }
    if (correct > 0) {
      setState(() {
        _score += correct * _pointsPer;
        _streak++; // Increment streak for correct submission
        if (_streak % 3 == 0) {
          _remainingTime += 10; // Add 10 seconds every 3 pyramids
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "🔥 3-Streak! +10s Bonus!",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orangeAccent,
            ),
          );
          AudioService.playSfx('sounds/coin.wav'); // Optional: Play bonus sound
        }
      });
      AudioService.playSfx('sounds/right.wav');
    } else {
      setState(() {
        _streak = 0; // Reset streak on incorrect submission
      });
      AudioService.playSfx('sounds/wrong.wav');
    }
    _generateNewPuzzle();
  }

  void _endGame() async {
    _timer.cancel();
    await _updateCoin();
    if (_score <= 0) {
      AudioService.playSfx('sounds/lose.wav');
    } else {
      AudioService.playSfx('sounds/win.wav');
    }
    Navigator.pop(context);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultfScreen(
              user: widget.user,
              score: _score,
              difficulty: widget.difficulty,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLarge = screenWidth > 600;
    final double cellSize = isLarge ? 60 : screenWidth * 0.13;
    final double fontSize = isLarge ? 18 : screenWidth * 0.04;
    final double spacing = isLarge ? 8 : screenWidth * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧮 Number Pyramid'),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: fontSize),
          onPressed: () {
            _timer.cancel();
            _endGame();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing * 2),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time: $_remainingTime',
                  style: TextStyle(fontSize: fontSize),
                ),
                Text('Score: $_score', style: TextStyle(fontSize: fontSize)),
              ],
            ),
            SizedBox(height: spacing * 2),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_levels, (r) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pyramidDisplay[r].length, (c) {
                      final val = _pyramidDisplay[r][c];
                      if (val == null) {
                        return GestureDetector(
                          onTap:
                              () =>
                                  _showOptionsDialog(r, c, cellSize, fontSize),
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            margin: EdgeInsets.all(spacing),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(spacing),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '?',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: EdgeInsets.all(spacing),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(spacing),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            val,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                            ),
                          ),
                        );
                      }
                    }),
                  ),
                );
              }),
            ),
            SizedBox(height: spacing * 2),
            SizedBox(
              width: cellSize * 3,
              height: cellSize * 0.7,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: spacing),
                  textStyle: TextStyle(fontSize: fontSize),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(fontFamily: 'ComicSans'),
                ),
              ),
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
          'coin': _score.toString(),
          'game': 'Number Pyramid',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          setState(() {
            widget.user.coin =
                (int.parse(widget.user.coin.toString()) + _score).toString();
          });
        }
      }
    } catch (e) {
      // handle error silently
    } finally {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultfScreen(
                user: widget.user,
                score: _score,
                difficulty: widget.difficulty,
              ),
        ),
      );
    }
  }
}
