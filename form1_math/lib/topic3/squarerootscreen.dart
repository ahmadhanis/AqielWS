import 'dart:math';

import 'package:flutter/material.dart';

class SquareRootScreen extends StatefulWidget {
  const SquareRootScreen({super.key});

  @override
  State<SquareRootScreen> createState() => _SquareRootScreenState();
}

class _SquareRootScreenState extends State<SquareRootScreen> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = "";
  double? _square;
  double? _squareRoot;
  bool? _isPerfectSquare;
  String _primeFactorization = "";

  /// Computes the prime factorization of a positive integer.
  /// Returns a string in the form: "2 x 2 x 3 x 3" for 36.
  String primeFactorization(int n) {
    if (n < 2) return n.toString();

    List<int> factors = [];
    int num = n;
    // Factor out 2's.
    while (num % 2 == 0) {
      factors.add(2);
      num ~/= 2;
    }
    // Factor out odd numbers.
    for (int i = 3; i <= sqrt(num).toInt(); i += 2) {
      while (num % i == 0) {
        factors.add(i);
        num ~/= i;
      }
    }
    // If the remaining num is a prime greater than 2.
    if (num > 2) {
      factors.add(num);
    }
    return factors.join(" x ");
  }

  /// Performs the calculations based on the input.
  void _calculate() {
    setState(() {
      _errorMessage = "";
      _square = null;
      _squareRoot = null;
      _isPerfectSquare = null;
      _primeFactorization = "";
    });

    String input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a number.";
      });
      return;
    }

    // Try to parse the input as a double.
    double? parsedNumber = double.tryParse(input);
    if (parsedNumber == null) {
      setState(() {
        _errorMessage = "Invalid number.";
      });
      return;
    }

    // Calculate the square.
    _square = parsedNumber * parsedNumber;

    // Calculate the square root if non-negative.
    if (parsedNumber < 0) {
      _squareRoot = double.nan;
      _isPerfectSquare = false;
    } else {
      _squareRoot = sqrt(parsedNumber);
      // Check if the number is a perfect square:
      int srInt = _squareRoot!.round();
      _isPerfectSquare = (srInt * srInt == parsedNumber);
    }

    // If the input can be parsed as an integer, calculate prime factorization.
    int? intNumber = int.tryParse(input);
    if (intNumber != null) {
      _primeFactorization = primeFactorization(intNumber);
    }

    setState(() {}); // Refresh the UI.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Square & Root Calculator"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.lightBlue, width: 2),
                ),
                child: const Text(
                  "Square: A number times itself. (e.g., 5 x 5 = 25)\n"
                  "Square Root: A number which, when squared, returns the original number. (e.g., √25 = 5)",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              TextField(
                controller: _controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Enter a number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text("Calculate"),
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_square != null &&
                  _squareRoot != null &&
                  _isPerfectSquare != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Square: $_square",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Square Root: ${_squareRoot!.isNaN ? "NaN" : _squareRoot!.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Is Perfect Square: ${_isPerfectSquare! ? "Yes" : "No"}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      if (_primeFactorization.isNotEmpty)
                        Text(
                          "Prime Factorization: $_primeFactorization",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
