import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';

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

  @override
  void initState() {
    super.initState();
    _generateGrid();
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
        _showResultDialog(true);
      } else if (currentSum > widget.target) {
        _showResultDialog(false);
      }
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Exit to main screen
                },
                child: const Text("Exit"),
              ),
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
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Math Maze"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Target Info
            Text(
              "🎯 Target: ${widget.target}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Sum: $currentSum",
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Grid
            _buildGrid(),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _generateGrid();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Reset Grid"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
