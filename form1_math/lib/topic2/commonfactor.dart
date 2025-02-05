import 'package:flutter/material.dart';

class CommonFactorScreen extends StatefulWidget {
  const CommonFactorScreen({super.key});

  @override
  State<CommonFactorScreen> createState() => _CommonFactorScreenState();
}

class _CommonFactorScreenState extends State<CommonFactorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';
  int? _selectedCommonFactor; // Chosen common factor based on our rule.
  List<int> _allCommonFactors = []; // All common factors across the numbers.
  Map<int, List<int>> _factorsForEach =
      {}; // Factors for each individual number.

  /// Returns a set of all factors of [n].
  Set<int> _getFactors(int n) {
    Set<int> factors = {};
    // Loop from 1 to n (inclusive) to find factors.
    for (int i = 1; i <= n; i++) {
      if (n % i == 0) {
        factors.add(i);
      }
    }
    return factors;
  }

  /// Parses the input, computes factors for each number,
  /// finds the common factors (intersection),
  /// selects one common factor according to the rule:
  /// - For 2 numbers: choose the second largest common factor.
  /// - For more than 2 numbers: choose the largest common factor.
  void _computeCommonFactor() {
    // Remove spaces and split the input by commas.
    String input = _controller.text.replaceAll(' ', '');
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a series of numbers separated by commas.';
        _selectedCommonFactor = null;
        _allCommonFactors = [];
        _factorsForEach = {};
      });
      return;
    }

    // Convert the input strings into a list of integers.
    List<String> parts = input.split(',');
    List<int> numbers = [];
    try {
      numbers = parts.map((part) => int.parse(part)).toList();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Invalid input. Please ensure you enter only integers separated by commas.';
        _selectedCommonFactor = null;
        _allCommonFactors = [];
        _factorsForEach = {};
      });
      return;
    }

    // Ensure all numbers are positive.
    if (numbers.any((number) => number <= 0)) {
      setState(() {
        _errorMessage = 'Please enter positive integers only.';
        _selectedCommonFactor = null;
        _allCommonFactors = [];
        _factorsForEach = {};
      });
      return;
    }

    // Clear any previous error.
    setState(() {
      _errorMessage = '';
    });

    // Calculate factors for each individual number.
    Map<int, List<int>> individualFactors = {};
    for (int num in numbers) {
      List<int> factors = _getFactors(num).toList()..sort();
      individualFactors[num] = factors;
    }
    _factorsForEach = individualFactors;

    // Compute the common factors across all numbers.
    Set<int> common = _getFactors(numbers.first);
    for (int i = 1; i < numbers.length; i++) {
      common = common.intersection(_getFactors(numbers[i]));
    }
    List<int> sortedCommon = common.toList()..sort();
    _allCommonFactors = sortedCommon;

    // Now select one common factor based on the rule.
    // For two numbers: choose the second-largest common factor if available.
    // For more than two numbers: choose the largest common factor.
    int chosen;
    if (numbers.length == 2) {
      if (sortedCommon.length >= 2) {
        chosen = sortedCommon[sortedCommon.length - 2];
      } else {
        chosen = sortedCommon.last;
      }
    } else {
      chosen = sortedCommon.last;
    }

    setState(() {
      _selectedCommonFactor = chosen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine lowest and highest common factor from _allCommonFactors, if available.
    int? lowestCommon =
        _allCommonFactors.isNotEmpty ? _allCommonFactors.first : null;
    int? highestCommon =
        _allCommonFactors.isNotEmpty ? _allCommonFactors.last : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Common Factors Calculator'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // Align contents in the center.
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Input field for comma-separated numbers.
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: const Text(
                    "Common factors are numbers that evenly divide each of the given numbers. For example, the common factors of 12, 18, and 24 are 1, 2, 3, and 6.",
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Enter numbers (e.g., 24, 36 or 16, 32, 48, 72)',
                    border: OutlineInputBorder(),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Button to compute factors.
                ElevatedButton(
                  onPressed: _computeCommonFactor,
                  child: const Text('Calculate Common Factor'),
                ),
                const SizedBox(height: 16.0),
                // Display all common factors.
                if (_allCommonFactors.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'All Common Factors',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: _allCommonFactors.map((factor) {
                            return Chip(
                              label: Text(
                                factor.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              backgroundColor: Colors.green.shade200,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12.0),
                        if (lowestCommon != null && highestCommon != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lowest: $lowestCommon',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Highest: $highestCommon',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16.0),
                // Display individual factors for each number.
                if (_factorsForEach.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _factorsForEach.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Factors for ${entry.key}:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: entry.value.map<Widget>((factor) {
                                  return Chip(
                                    label: Text(
                                      factor.toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    backgroundColor: Colors.orange.shade200,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
