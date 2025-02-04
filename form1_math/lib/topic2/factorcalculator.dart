import 'dart:math';

import 'package:flutter/material.dart';

class FactorCalculator extends StatefulWidget {
  const FactorCalculator({super.key});

  @override
  _FactorCalculatorState createState() => _FactorCalculatorState();
}

class _FactorCalculatorState extends State<FactorCalculator> {
  final TextEditingController _controller = TextEditingController();
  List<int> _factors = [];
  String _errorMessage = '';

  /// Optimized calculation of factors using the square root method.
  void _calculateFactors() {
    // Try parsing the input into an integer.
    int? number = int.tryParse(_controller.text);

    // Validate the input.
    if (number == null || number <= 0) {
      setState(() {
        _factors = [];
        _errorMessage = 'Please enter a valid positive integer.';
      });
      return;
    }

    // Clear previous error message.
    setState(() {
      _errorMessage = '';
    });

    Set<int> factorsSet = {};

    // Loop only up to the square root of the number.
    int limit = sqrt(number).floor();
    for (int i = 1; i <= limit; i++) {
      if (number % i == 0) {
        // Add both factors: i and number/i.
        factorsSet.add(i);
        factorsSet.add(number ~/ i);
      }
    }

    // Convert the set to a sorted list.
    List<int> factors = factorsSet.toList()..sort();

    setState(() {
      _factors = factors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factor Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field for the number.
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter a positive integer',
                border: const OutlineInputBorder(),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            const SizedBox(height: 16.0),
            // Button to calculate factors.
            ElevatedButton(
              onPressed: _calculateFactors,
              child: const Text('Calculate Factors'),
            ),
            const SizedBox(height: 16.0),
            // Display the calculated factors if available.
            if (_factors.isNotEmpty)
              Text(
                'Factors: ${_factors.join(', ')}',
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
