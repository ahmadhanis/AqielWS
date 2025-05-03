import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedBackScreen extends StatefulWidget {
  final int userId;
  const FeedBackScreen({super.key, required this.userId});

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  double uiRating = 3;
  double featuresRating = 3;
  double reportRating = 3;
  double overallRating = 3;
  final TextEditingController commentController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _submitFeedback() async {
    final url = Uri.parse(
        'https://slumberjer.com/mybudget/submit_feedback.php'); // Replace with your real endpoint

    final Map<String, dynamic> data = {
      'user_id': widget.userId,
      'ui_rating': uiRating.toInt(),
      'features_rating': featuresRating.toInt(),
      'report_rating': reportRating.toInt(),
      'overall_rating': overallRating.toInt(),
      'comment': commentController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
        commentController.clear();
        setState(() {
          uiRating = featuresRating = reportRating = overallRating = 3;
        });

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildSlider(
      String title, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFeedbackForm(BoxConstraints constraints) {
    return Center(
      child: Container(
        width: constraints.maxWidth > 600 ? 600 : double.infinity,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please rate each aspect from 1 to 5:\n"
                "1 = Very Poor, 2 = Poor, 3 = Fair, 4 = Good, 5 = Excellent",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              _buildSlider("1. User Interface Rating", uiRating,
                  (val) => setState(() => uiRating = val)),
              _buildSlider("2. Features Rating", featuresRating,
                  (val) => setState(() => featuresRating = val)),
              _buildSlider("3. Report Rating", reportRating,
                  (val) => setState(() => reportRating = val)),
              _buildSlider("4. Overall Rating", overallRating,
                  (val) => setState(() => overallRating = val)),
              const SizedBox(height: 20),
              const Text("5. Comment",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Enter your feedback...",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your comment.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Center(
                  child: ElevatedButton.icon(
                onPressed: _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text(
                  "Submit Feedback",
                  style: TextStyle(color: Colors.white),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: _buildFeedbackForm(constraints),
        ),
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
