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
  late double screenHeight, screenWidth;

  double get totalPayment => widget.amount * 0.50;

  void _simulatePayment() async {
    setState(() => _isPaying = true);

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}api/buy_credit.php"),
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
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Credit"),
        backgroundColor: Colors.amber.shade900,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.credit_score_rounded,
                      size: 48,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Credit Purchase",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "⚠ Currently, this is a simulated payment. No real transaction will be made.\n\nThe app is under development. Future integration with real payment systems will be added.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Current Credits: ${widget.currentCredit}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_cart_checkout_rounded,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Credit Amount to Buy: ${widget.amount} credits",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Total Payment: RM ${totalPayment.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.amber.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isPaying ? null : _simulatePayment,
                        icon: const Icon(Icons.payment),
                        label:
                            _isPaying
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "Pay Now",
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
