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
  double usabilityRating = 3;
  double performanceRating = 3;
  double recommendationRating = 3;
  double usefulnessRating = 3;
  String frequency = 'Daily';

  final List<String> frequencyOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Rarely',
  ];

  final TextEditingController commentController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final url =
        Uri.parse('https://slumberjer.com/mybudget/submit_feedback.php');
    final Map<String, dynamic> data = {
      'user_id': widget.userId,
      'ui_rating': uiRating.toInt(),
      'features_rating': featuresRating.toInt(),
      'report_rating': reportRating.toInt(),
      'overall_rating': overallRating.toInt(),
      'usability_rating': usabilityRating.toInt(),
      'performance_rating': performanceRating.toInt(),
      'recommendation_rating': recommendationRating.toInt(),
      'usefulness_rating': usefulnessRating.toInt(),
      'usage_frequency': frequency,
      'comment': commentController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        commentController.clear();
        setState(() {
          uiRating = featuresRating = reportRating = overallRating = 3;
        });

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Thank You!"),
            content:
                const Text("Your feedback has been submitted successfully."),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

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

  Widget _buildSlider(String title, double value,
      ValueChanged<double> onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ]),
    );
  }

  Widget _buildFeedbackForm(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isWide ? 600 : double.infinity,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Rate each aspect from 1 to 5:\n1 = Very Poor, 5 = Excellent",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              _buildSlider("1. User Interface", uiRating,
                  (val) => setState(() => uiRating = val), Icons.devices),
              _buildSlider(
                  "2. Features",
                  featuresRating,
                  (val) => setState(() => featuresRating = val),
                  Icons.extension),
              _buildSlider(
                  "3. Reports",
                  reportRating,
                  (val) => setState(() => reportRating = val),
                  Icons.insert_chart),
              _buildSlider("4. Overall", overallRating,
                  (val) => setState(() => overallRating = val), Icons.star),
              _buildSlider(
                  "5. Usability",
                  usabilityRating,
                  (val) => setState(() => usabilityRating = val),
                  Icons.accessibility),
              _buildSlider(
                  "6. Performance",
                  performanceRating,
                  (val) => setState(() => performanceRating = val),
                  Icons.speed),
              _buildSlider(
                  "7. Recommendation",
                  recommendationRating,
                  (val) => setState(() => recommendationRating = val),
                  Icons.thumb_up),
              _buildSlider(
                  "8. Usefulness",
                  usefulnessRating,
                  (val) => setState(() => usefulnessRating = val),
                  Icons.lightbulb),
              const SizedBox(height: 16),
              const Text("9. Frequency of Use",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: frequency,
                onChanged: (value) => setState(() => frequency = value!),
                items: frequencyOptions.map((f) {
                  return DropdownMenuItem(value: f, child: Text(f));
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 20),
              const Text("5. Comments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your feedback...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white, // White text and icon
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitFeedback,
                  icon: const Icon(Icons.send),
                  label: const Text("Submit Feedback"),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Feedback"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildFeedbackForm(constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
