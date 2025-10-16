// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathwizard/gameg/resultgscreen.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GameGScreen extends StatefulWidget {
  final User user;
  final String difficulty; // 'Beginner' | 'Intermediate' | 'Advanced'
  final String mode; // 'Prime Finder' | 'Composite Catch' | 'Twin Prime Rush'
  final int minValue; // e.g. 1
  final int maxValue; // e.g. 50 / 150 / 500

  const GameGScreen({
    super.key,
    required this.user,
    required this.difficulty,
    required this.mode,
    required this.minValue,
    required this.maxValue,
  });

  @override
  State<GameGScreen> createState() => _GameGScreenState();
}

class _GameGScreenState extends State<GameGScreen> {
  late Timer _timer;
  int _timeLeft = 60;
  int _score = 0;

  late int _gridSide;
  late int _pointsPer;
  late int _penaltyPer;

  final Random _rand = Random();

  // Board state
  late List<int> _numbers; // numbers shown in grid cells
  late Set<int> _correctIndices; // which cell indices are correct answers
  late List<_TileState> _tileStates; // for quick flash feedback

  @override
  void initState() {
    super.initState();
    _configureDifficulty();
    _generateBoard();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // -------------------- Setup --------------------

  void _configureDifficulty() {
    switch (widget.difficulty) {
      case 'Intermediate':
        _gridSide = 5;
        _pointsPer = 2;
        _penaltyPer = 2;
        break;
      case 'Advanced':
        _gridSide = 6;
        _pointsPer = 3;
        _penaltyPer = 3;
        break;
      default:
        _gridSide = 4;
        _pointsPer = 1;
        _penaltyPer = 1;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        _finishGame();
      }
    });
  }

  // -------------------- Board Generation --------------------

  void _generateBoard() {
    final count = _gridSide * _gridSide;

    // Make numbers within range (avoid 0; optionally avoid 1 to reduce confusion)
    _numbers = List.generate(
      count,
      (_) => _randInRange(max(widget.minValue, 2), widget.maxValue),
    );

    // Precompute primes up to maxValue (for speed)
    final isPrimeArr = _sieve(widget.maxValue);

    // Compute correctness per mode
    _correctIndices = {};
    if (widget.mode == 'Prime Finder') {
      for (int i = 0; i < count; i++) {
        final n = _numbers[i];
        if (n >= 2 && isPrimeArr[n]) _correctIndices.add(i);
      }
    } else if (widget.mode == 'Composite Catch') {
      for (int i = 0; i < count; i++) {
        final n = _numbers[i];
        // Composite: n>1 and not prime
        if (n > 1 && !isPrimeArr[n]) _correctIndices.add(i);
      }
    } else {
      // Twin Prime Rush: a cell is correct if it is prime and has a twin partner (p±2) also prime (within range)
      for (int i = 0; i < count; i++) {
        final p = _numbers[i];
        if (p >= 2 && isPrimeArr[p]) {
          final hasTwin =
              (p + 2 <= widget.maxValue && isPrimeArr[p + 2]) ||
              (p - 2 >= 2 && isPrimeArr[p - 2]);
          if (hasTwin) _correctIndices.add(i);
        }
      }
    }

    // Ensure at least one correct candidate; if none, regenerate
    if (_correctIndices.isEmpty) {
      _generateBoard();
      return;
    }

    _tileStates = List.filled(count, _TileState.normal);
    setState(() {});
  }

  // -------------------- Interaction --------------------

  void _handleTap(int idx) async {
    if (_tileStates[idx] == _TileState.disabled) return;

    final correct = _correctIndices.contains(idx);
    if (correct) {
      _score += _pointsPer;
      _tileStates[idx] = _TileState.correct;
      _correctIndices.remove(idx); // prevent double scoring
      await AudioService.playSfx('sounds/right.wav');
    } else {
      _score -= _penaltyPer;
      _tileStates[idx] = _TileState.wrong;
      await AudioService.playSfx('sounds/wrong.wav');
    }
    setState(() {});

    // Reset flash and optionally disable after feedback
    Future.delayed(const Duration(milliseconds: 220), () {
      setState(() {
        _tileStates[idx] = correct ? _TileState.disabled : _TileState.normal;
      });
    });

    // If all correct tapped, regenerate a fresh board
    if (_correctIndices.isEmpty) {
      await AudioService.playSfx('sounds/coin.wav');
      _generateBoard();
    }
  }

  // -------------------- Finish / Backend --------------------

  Future<void> _finishGame() async {
    // Update coins on server like your other games
    try {
      final res = await http.post(
        Uri.parse("https://slumberjer.com/mathwizard/api/update_coin.php"),
        body: {
          'userid': widget.user.userId.toString(),
          'coin': _score.toString(),
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          widget.user.coin =
              (int.parse(widget.user.coin.toString()) + _score).toString();
        }
      }
    } catch (_) {}

    // Navigate to result screen (create a simple ResultGScreen similar to others)
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultGScreen(
              user: widget.user,
              score: _score,
              difficulty: widget.difficulty,
              mode: widget.mode,
            ),
      ),
    );
  }

  // -------------------- Utils --------------------

  int _randInRange(int min, int max) => min + _rand.nextInt(max - min + 1);

  /// Sieve of Eratosthenes (true if index is prime)
  List<bool> _sieve(int n) {
    final isPrime = List<bool>.filled(n + 1, true);
    if (n >= 0) isPrime[0] = false;
    if (n >= 1) isPrime[1] = false;
    for (int p = 2; p * p <= n; p++) {
      if (isPrime[p]) {
        for (int k = p * p; k <= n; k += p) {
          isPrime[k] = false;
        }
      }
    }
    return isPrime;
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;
    final cell = isWide ? 72.0 : max(56.0, size.width / (_gridSide + 2));
    final font = cell * 0.38;

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Prime Time • ${widget.difficulty}"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer.cancel();
            _finishGame();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isWide ? 16 : 12),
          child: Column(
            children: [
              // Header row: time + score + mode chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "⏱ $_timeLeft",
                    style: TextStyle(
                      fontSize: isWide ? 22 : 18,
                      color: Colors.red,
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.tune, size: 18),
                    label: Text(widget.mode),
                  ),
                  Text(
                    "⭐ $_score",
                    style: TextStyle(
                      fontSize: isWide ? 22 : 18,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grid
              Expanded(
                child: Center(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSide,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _gridSide * _gridSide,
                    itemBuilder: (_, i) {
                      final n = _numbers[i];
                      final state = _tileStates[i];
                      Color bg;
                      switch (state) {
                        case _TileState.correct:
                          bg = Colors.green;
                          break;
                        case _TileState.wrong:
                          bg = Colors.redAccent;
                          break;
                        case _TileState.disabled:
                          bg = Colors.grey.shade400;
                          break;
                        default:
                          bg = Colors.white;
                      }
                      return InkWell(
                        onTap: () => _handleTap(i),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.shade100,
                            ),
                            boxShadow: [
                              if (state == _TileState.normal)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$n",
                            style: TextStyle(
                              fontSize: font,
                              fontWeight: FontWeight.w700,
                              color:
                                  state == _TileState.normal
                                      ? Colors.black87
                                      : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Refresh board (optional helper)
              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: _generateBoard,
                  icon: const Icon(Icons.refresh),
                  label: const Text("New Board"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TileState { normal, correct, wrong, disabled }
