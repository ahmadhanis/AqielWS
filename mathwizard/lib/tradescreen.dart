import 'package:flutter/material.dart';
import 'package:mathwizard/models/user.dart';

class TradeScreen extends StatefulWidget {
  final User user;

  const TradeScreen({super.key, required this.user});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  List<String> myItems = ["Math Puzzle Book", "Nintendo Switch", "Calculator"];

  List<Map<String, String>> marketplace = [
    {"name": "Digital Watch", "owner": "User A"},
    {"name": "Board Game", "owner": "User B"},
    {"name": "Scientific Calculator", "owner": "User C"},
  ];

  void _initiateTrade(Map<String, String> item) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Trade Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Do you want to trade for ${item['name']}?"),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  items:
                      myItems.map((myItem) {
                        return DropdownMenuItem(
                          value: myItem,
                          child: Text(myItem),
                        );
                      }).toList(),
                  onChanged: (value) {
                    // Handle item selection for trade
                  },
                  decoration: const InputDecoration(
                    labelText: "Select Your Item to Trade",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Submit trade request
                  Navigator.pop(context);
                },
                child: const Text("Confirm Trade"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trade Marketplace")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User's items
            const Text(
              "Your Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Center(
              child: Text(
                "Under Development!!!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: myItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Chip(
                      label: Text(myItems[index]),
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Marketplace
            const Text(
              "Available Trades",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: marketplace.length,
                itemBuilder: (context, index) {
                  final item = marketplace[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(item['name']!),
                      subtitle: Text("Owned by: ${item['owner']}"),
                      trailing: ElevatedButton(
                        onPressed: () => _initiateTrade(item),
                        child: const Text("Trade"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
