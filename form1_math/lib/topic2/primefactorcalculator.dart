import 'dart:math';

import 'package:flutter/material.dart';

class PrimeFactorCalculator extends StatefulWidget {
  @override
  _PrimeFactorCalculatorState createState() => _PrimeFactorCalculatorState();
}

class _PrimeFactorCalculatorState extends State<PrimeFactorCalculator> {
  final TextEditingController _controller = TextEditingController();
  List<int> _primeFactors = [];
  String _errorMessage = '';

  /// Calculates the prime factors of the entered number.
  void _calculatePrimeFactors() {
    // Try to parse the input as an integer.
    int? number = int.tryParse(_controller.text);

    // Validate the input: it should be an integer greater than 1.
    if (number == null || number <= 1) {
      setState(() {
        _primeFactors = [];
        _errorMessage = 'Please enter an integer greater than 1.';
      });
      return;
    }

    // Clear any previous error message.
    setState(() {
      _errorMessage = '';
    });

    int n = number;
    List<int> factors = [];

    // Divide out the factor 2 as many times as possible.
    while (n % 2 == 0) {
      factors.add(2);
      n ~/= 2;
    }

    // Now, n must be odd. Check for odd factors from 3 up to the square root of n.
    for (int i = 3; i <= sqrt(n).toInt(); i += 2) {
      while (n % i == 0) {
        factors.add(i);
        n ~/= i;
      }
    }

    // If n is a prime number greater than 2, add it to the list.
    if (n > 2) {
      factors.add(n);
    }

    // Update the state with the calculated factors.
    setState(() {
      _primeFactors = factors;
    });
  }

  List<int> generatePrimes() {
    List<int> primes = [];
    for (int number = 2; number <= 100; number++) {
      if (isPrime(number)) {
        primes.add(number);
      }
    }
    return primes;
  }

  /// Returns true if [number] is prime.
  bool isPrime(int number) {
    if (number <= 1) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;

    // Only check odd divisors up to the square root of the number.
    int limit = sqrt(number).toInt();
    for (int i = 3; i <= limit; i += 2) {
      if (number % i == 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<int> primes = generatePrimes();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prime Factor Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(8.00),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Text(
                  "A prime factor is a prime number that divides another number exactly.\n\n"
                  "Example: The prime factors of 18 are 2 and 3, because 18 = 2 × 3 × 3.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8.0),
              // Input field for the number.
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter an integer greater than 1',
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                ),
              ),
              const SizedBox(height: 16.0),
              // Button to trigger the prime factor calculation.
              ElevatedButton(
                onPressed: _calculatePrimeFactors,
                child: const Text('Calculate Prime Factors'),
              ),
              const SizedBox(height: 16.0),
              // Display the calculated prime factors if available.

              if (_primeFactors.isNotEmpty)
                const Text(
                  'Prime Factors:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _primeFactors
                    .map((factor) => Chip(
                          label: Text(
                            factor.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          backgroundColor: Colors.blue.shade100,
                        ))
                    .toList(),
              ),
              const Divider(
                color: Colors.blue,
                thickness: 2,
              ),
              const SizedBox(height: 16.0),
              // const SizedBox(height: 16.0),
              // Display the prime numbers from 2 to 100.

              const Text(
                'Prime Numbers from 2 to 100:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                // Styling the outer container.
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Use Wrap to arrange prime number boxes.
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: primes.map((prime) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        prime.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
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
