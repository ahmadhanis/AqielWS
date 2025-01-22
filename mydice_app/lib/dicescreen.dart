import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  int diceNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('MyDice'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 200,
                width: 200,
                color: Colors.grey,
                child: Text(diceNumber.toString(),
                    style: TextStyle(fontSize: 128)),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: onPressed, child: const Text('Roll Dice')),
            ],
          ),
        ));
  }

  void onPressed() {
    // TODO: implement onPressed

    var random = Random();
    for (var i = 0; i < 20; i++) {
      Timer(Duration(milliseconds: 100 * i), () {
        setState(() {
          diceNumber = random.nextInt(6) + 1;
        });
      });
    }
  }
}
