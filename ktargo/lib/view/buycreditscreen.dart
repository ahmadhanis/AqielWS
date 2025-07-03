// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ktargo/model/user.dart';
import 'dart:convert';

import 'package:ktargo/shared/myconfig.dart';

class BuyCreditScreen extends StatefulWidget {
  final User user;
  final int amount;
  final int currentCredit;
  final Function(int newCredit) onSuccess;

  const BuyCreditScreen({
    super.key,
    required this.amount,
    required this.currentCredit,
    required this.onSuccess,
    required this.user,
  });

  @override
  State<BuyCreditScreen> createState() => _BuyCreditScreenState();
}

class _BuyCreditScreenState extends State<BuyCreditScreen> {
  bool _isPaying = false;

  double get totalPayment => widget.amount * 0.50;

  void _simulatePayment() async {
    setState(() => _isPaying = true);

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}ktargo/php/buy_credit.php"),
      body: {"userid": widget.user.userId, "amount": widget.amount.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final newCredit = widget.currentCredit + widget.amount;
        widget.onSuccess(newCredit);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful! Credits added.")),
        );
        Navigator.pop(context);
      } else {
        _showError("Payment failed: ${data['message']}");
      }
    } else {
      _showError("Server error, try again.");
    }

    setState(() => _isPaying = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Credit"),
        elevation: 0,
        backgroundColor: Colors.amber.shade900,
      ),
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Credit Purchase", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                Text("Amount: ${widget.amount} credits"),
                Text("Total: RM ${totalPayment.toStringAsFixed(2)}"),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isPaying ? null : _simulatePayment,
                  icon: const Icon(Icons.payment),
                  label:
                      _isPaying
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text("Pay Now"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
