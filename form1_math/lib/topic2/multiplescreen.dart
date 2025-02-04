import 'package:flutter/material.dart';

class MultipleScreen extends StatefulWidget {
  const MultipleScreen({super.key});

  @override
  State<MultipleScreen> createState() => _MultipleScreenState();
}

class _MultipleScreenState extends State<MultipleScreen> {
  final TextEditingController _numbersController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  String _errorMessage = '';
  List<int> _commonMultiples = [];
  Map<int, List<int>> _multiplesForEach =
      {}; // Multiples for each individual number.

  /// Calculates common multiples up to [max] for the given list of numbers.
  List<int> _calculateCommonMultiples(List<int> numbers, int max) {
    List<int> multiples = [];
    // Loop through numbers from 1 to max.
    for (int i = 1; i <= max; i++) {
      // Check if i is divisible by every number in the list.
      bool isCommonMultiple = numbers.every((num) => i % num == 0);
      if (isCommonMultiple) {
        multiples.add(i);
      }
    }
    return multiples;
  }

  /// Calculates multiples for each individual number up to [max].
  Map<int, List<int>> _calculateMultiplesForEach(List<int> numbers, int max) {
    Map<int, List<int>> multiplesMap = {};
    for (int num in numbers) {
      List<int> multiples = [];
      // Start from the number itself up to max.
      for (int i = num; i <= max; i++) {
        if (i % num == 0) {
          multiples.add(i);
        }
      }
      multiplesMap[num] = multiples;
    }
    return multiplesMap;
  }

  /// Parses the input, computes the common multiples and the individual multiples,
  /// and updates the state.
  void _computeMultiples() {
    // Clear previous error message and results.
    setState(() {
      _errorMessage = '';
      _commonMultiples = [];
      _multiplesForEach = {};
    });

    // Remove any extra spaces.
    String numbersInput = _numbersController.text.replaceAll(' ', '');
    String maxInput = _maxController.text.replaceAll(' ', '');

    if (numbersInput.isEmpty || maxInput.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter both a series of numbers and a maximum value.';
      });
      return;
    }

    // Parse the comma-separated numbers.
    List<String> parts = numbersInput.split(',');
    List<int> numbers = [];
    try {
      numbers = parts.map((part) => int.parse(part)).toList();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Invalid input for numbers. Please ensure you enter only integers separated by commas.';
      });
      return;
    }

    // Parse the maximum value.
    int max;
    try {
      max = int.parse(maxInput);
    } catch (e) {
      setState(() {
        _errorMessage =
            'Invalid maximum value. Please enter a valid integer for the maximum.';
      });
      return;
    }

    // Ensure all numbers and max are positive.
    if (numbers.any((num) => num <= 0) || max <= 0) {
      setState(() {
        _errorMessage = 'Please enter positive integers only.';
      });
      return;
    }

    // Calculate the common multiples.
    List<int> multiples = _calculateCommonMultiples(numbers, max);
    // Calculate the multiples for each individual number.
    Map<int, List<int>> multiplesMap = _calculateMultiplesForEach(numbers, max);

    setState(() {
      _commonMultiples = multiples;
      _multiplesForEach = multiplesMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The smallest common multiple is the first value from the _commonMultiples list.
    int? smallestCommonMultiple =
        _commonMultiples.isNotEmpty ? _commonMultiples.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Common Multiple Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input for comma-separated numbers.
              TextField(
                controller: _numbersController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Enter numbers (e.g., 2, 8)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              // Input for maximum value.
              TextField(
                controller: _maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter maximum value (e.g., 32)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              // Button to calculate multiples.
              ElevatedButton(
                onPressed: _computeMultiples,
                child: const Text('Calculate Multiples'),
              ),
              const SizedBox(height: 16.0),
              // Display error message if any.
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              // Display the common multiples and the smallest common multiple.
              if (_commonMultiples.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Common Multiples: ${_commonMultiples.join(', ')}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      if (smallestCommonMultiple != null)
                        Text(
                          'Smallest Common Multiple: $smallestCommonMultiple',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                )
              else if (_errorMessage.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No common multiples found in the given range.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16.0),
              // Display individual multiples for each number.
              if (_multiplesForEach.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _multiplesForEach.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Multiples for ${entry.key}: ${entry.value.join(', ')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
