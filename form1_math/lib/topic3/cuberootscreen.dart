import 'dart:math';
import 'package:flutter/material.dart';

class CubeRootScreen extends StatefulWidget {
  const CubeRootScreen({super.key});

  @override
  State<CubeRootScreen> createState() => _CubeRootScreenState();
}

class _CubeRootScreenState extends State<CubeRootScreen> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = "";
  double? _cube;
  double? _cubeRoot;
  bool? _isPerfectCube;
  String _primeFactorization = "";

  /// Computes the prime factorization of a positive integer.
  /// Returns a string in the form: "2 x 2 x 3" for 12.
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
      _cube = null;
      _cubeRoot = null;
      _isPerfectCube = null;
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

    // Calculate the cube.
    _cube = parsedNumber * parsedNumber * parsedNumber;

    // Calculate the cube root.
    if (parsedNumber < 0) {
      // For negative numbers, cube root is negative.
      _cubeRoot = -pow(-parsedNumber, 1 / 3).toDouble();
    } else {
      _cubeRoot = pow(parsedNumber, 1 / 3).toDouble();
    }

    // Check if the number is a perfect cube:
    // Round the cube root to the nearest integer and cube it.
    int cubeRootInt = _cubeRoot!.round();
    _isPerfectCube = (cubeRootInt * cubeRootInt * cubeRootInt == parsedNumber);

    // If the input can be parsed as an integer, calculate prime factorization.
    int? intNumber = int.tryParse(input);
    if (intNumber != null) {
      _primeFactorization = primeFactorization(intNumber);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cube & Root Calculator"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description Container
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.deepOrange, width: 2),
              ),
              child: const Text(
                "Cube: A number multiplied by itself 3 times. (e.g., 3 x 3 x 3 = 27)\n\n"
                "Cube Root: The number which, when cubed, gives the original number. (e.g., ∛27 = 3)",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            // Input Field
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Enter a number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Calculate Button
            ElevatedButton(
              onPressed: _calculate,
              child: const Text("Calculate"),
            ),
            const SizedBox(height: 16),
            // Error Message
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
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            // Results Container
            if (_cube != null && _cubeRoot != null && _isPerfectCube != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  border: Border.all(color: Colors.deepOrangeAccent),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cube: $_cube",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Cube Root: ${_cubeRoot!.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Is Perfect Cube: ${_isPerfectCube! ? "Yes" : "No"}",
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
    );
  }
}
