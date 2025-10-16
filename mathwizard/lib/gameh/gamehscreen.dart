// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mathwizard/models/audioservice.dart';
import 'package:mathwizard/models/user.dart';

import 'package:mathwizard/gameh/resulthscreen.dart'; // optional results

class GameHScreen extends StatefulWidget {
  final User user;
  final String difficulty; // Beginner | Intermediate | Advanced
  const GameHScreen({super.key, required this.user, required this.difficulty});

  @override
  State<GameHScreen> createState() => _GameHScreenState();
}

class _GameHScreenState extends State<GameHScreen> {
  late Timer _timer;
  int _timeLeft = 60;

  // Config per difficulty
  late int _targetBudget; // e.g., 50 / 100 / 200
  late int _itemsPerRound; // 6 / 8 / 10
  late int _minPrice; // 1 / 5 / 10
  late int _maxPrice; // 20 / 50 / 100
  late int _pointsPer; // 1 / 2 / 3

  // Round state
  final Random _rand = Random();
  late List<_ShopItem> _items;
  final Set<int> _selected = {};
  int _roundTotal = 0;

  // Score & streaks
  int _score = 0;
  int _exactStreak = 0; // every 3 exact matches => +10s

  @override
  void initState() {
    super.initState();
    _configureDifficulty();
    _newRound();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ---------- Setup ----------

  void _configureDifficulty() {
    switch (widget.difficulty) {
      case 'Intermediate':
        _targetBudget = 100;
        _itemsPerRound = 8;
        _minPrice = 5;
        _maxPrice = 50;
        _pointsPer = 2;
        break;
      case 'Advanced':
        _targetBudget = 200;
        _itemsPerRound = 10;
        _minPrice = 10;
        _maxPrice = 100;
        _pointsPer = 3;
        break;
      default:
        _targetBudget = 50;
        _itemsPerRound = 6;
        _minPrice = 1;
        _maxPrice = 20;
        _pointsPer = 1;
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

  // ---------- Round generation ----------

  void _newRound() {
    _items = _generateItems(_itemsPerRound, _minPrice, _maxPrice);
    _selected.clear();
    _recalcTotal();
    setState(() {});
  }

  List<_ShopItem> _generateItems(int count, int minPrice, int maxPrice) {
    final pool = [
      // 📚 School Supplies
      'Notebook', 'Pencil Set', 'Ruler', 'Eraser', 'Highlighter',
      'Glue Stick', 'Scissors', 'Markers', 'Crayons', 'Calculator',
      'Compass', 'Protractor', 'Stapler', 'Paper Clips', 'Correction Tape',
      'Binder', 'Folder', 'A4 Paper Pack', 'Index Cards', 'Pen Drive',

      // 🍎 Snacks & Drinks
      'Water Bottle', 'Juice Box', 'Sandwich', 'Apple', 'Banana',
      'Chips', 'Chocolate Bar', 'Energy Drink', 'Milk', 'Yogurt',
      'Biscuits', 'Muffin', 'Cup Noodles', 'Granola Bar', 'Coffee Cup',

      // 🎮 Entertainment & Toys
      'Playing Cards', 'Mini Puzzle', 'Yo-yo', 'Rubik’s Cube',
      'Coloring Book', 'Sticker Pack', 'Mini Plush', 'Comic Book',
      'Headphones', 'Bluetooth Speaker',

      // 🧼 Daily Use Items
      'Soap', 'Shampoo', 'Toothpaste', 'Toothbrush', 'Face Mask',
      'Hand Sanitizer', 'Tissue Pack', 'Deodorant', 'Comb', 'Wet Wipes',

      // 💡 Miscellaneous
      'Flashlight', 'Battery Pack', 'Umbrella', 'Keychain', 'Notepad',
      'Reusable Bag', 'Gift Card', 'Plant Seed Pack', 'Socks', 'T-shirt',
    ];
    pool.shuffle(_rand);

    pool.shuffle(_rand);
    return List.generate(
      count,
      (i) => _ShopItem(
        name: pool[i % pool.length],
        price: minPrice + _rand.nextInt(maxPrice - minPrice + 1),
      ),
    );
  }

  // ---------- Interaction ----------

  void _toggle(int idx) {
    if (_selected.contains(idx)) {
      _selected.remove(idx);
    } else {
      _selected.add(idx);
    }
    _recalcTotal();
    setState(() {});
  }

  void _recalcTotal() {
    _roundTotal = _selected.fold(0, (sum, i) => sum + _items[i].price);
  }

  // ---------- Scoring logic ----------
  //
  // Exact match: +_pointsPer + 5 bonus, streak++ (every 3 exact => +10s)
  // Under budget:
  //   within 5% => +_pointsPer
  //   within 15% => +(_pointsPer - 1) [min 0]
  //   else => +0
  // Over budget:
  //   within 5% => +0
  //   else => -_pointsPer
  //
  // After scoring, generate a fresh round (time continues).
  void _submitRound() async {
    final target = _targetBudget;
    final total = _roundTotal;
    final diff = (total - target).abs();
    final fivePct = (target * 0.05);
    final fifteenPct = (target * 0.15);

    int delta = 0;
    bool exact = false;

    if (total == target) {
      exact = true;
      delta += _pointsPer + 5;
      _exactStreak += 1;
      // Bonus every 3 exact matches
      if (_exactStreak % 3 == 0) {
        _timeLeft += 10;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🔥 Exact x3! +10s time bonus!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.teal,
          ),
        );
        await AudioService.playSfx('sounds/bonus.wav');
      }
      await AudioService.playSfx('sounds/coin.wav');
    } else if (total < target) {
      if (diff <= fivePct) {
        delta += _pointsPer;
      } else if (diff <= fifteenPct) {
        delta += max(0, _pointsPer - 1);
      } else {
        delta += 0;
      }
      _exactStreak = 0;
      await AudioService.playSfx('sounds/right.wav');
    } else {
      // overspend
      if (diff <= fivePct) {
        delta += 0;
      } else {
        delta -= _pointsPer;
      }
      _exactStreak = 0;
      await AudioService.playSfx('sounds/wrong.wav');
    }

    setState(() => _score += delta);

    // Quick feedback
    if (exact) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎯 Exact! +${_pointsPer + 5} points"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green[700],
        ),
      );
    } else if (delta > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Nice! +$delta"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green[400],
        ),
      );
    } else if (delta < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Overspent! $delta"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ℹ️ No points this round"),
          duration: Duration(seconds: 1),
        ),
      );
    }

    _newRound();
  }

  // ---------- Finish ----------
  Future<void> _finishGame() async {
    // TODO: Optionally POST _score to your API (update_coin.php) like other games,
    // then navigate to a ResultHScreen. For now we just pop with the score.
    if (!mounted) return;
    Navigator.pop(context, _score);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultHScreen(
              user: widget.user,
              score: _score,
              difficulty: widget.difficulty,
              onPlayAgain: () {
                // Re-enter Budget Hero quickly with the same settings:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => GameHScreen(
                          user: widget.user,
                          difficulty: widget.difficulty,
                        ),
                  ),
                );
              },
            ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 720;
    final gridCross = isWide ? 3 : 2;

    final remain = _targetBudget - _roundTotal;
    final remainColor = remain < 0 ? Colors.red : Colors.green[700];

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text("Budget Hero • ${widget.difficulty}"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _finishGame,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Top bar: time + score
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
                    avatar: const Icon(Icons.stars, size: 18),
                    label: Text("Score: $_score"),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Budget summary
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _pill("🎯 Target", "RM $_targetBudget"),
                          _pill("🛒 Selected", "RM $_roundTotal"),
                          _pill(
                            remain < 0 ? "❌ Over by" : "✅ Remaining",
                            "RM ${remain.abs()}",
                            color: remainColor!,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Tip: Hit the target exactly for +5 bonus! Every 3 exact hits adds +10s.",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Items grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCross,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isWide ? 2.6 : 2.2,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _itemTile(i, isWide),
                ),
              ),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _selected.clear();
                      _recalcTotal();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text("Clear Selection"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _submitRound,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Submit Round"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemTile(int idx, bool isWide) {
    final item = _items[idx];
    final selected = _selected.contains(idx);

    return InkWell(
      onTap: () => _toggle(idx),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? Colors.teal[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.teal : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected ? Colors.teal : Colors.grey.shade300,
              child: Text(
                item.name.characters.first,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "RM ${item.price}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.teal[900] : Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              selected ? Icons.check_circle : Icons.add_circle_outline,
              color: selected ? Colors.teal : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String title, String value, {Color color = Colors.black87}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem {
  final String name;
  final int price; // RM in whole units
  _ShopItem({required this.name, required this.price});
}
