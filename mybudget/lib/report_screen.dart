import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportScreen extends StatefulWidget {
  final int userId; // Assuming userId is passed to filter data per user
  const ReportScreen({super.key, required this.userId});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  late Future<List<BudgetItem>> futureBudgetItems;

  @override
  void initState() {
    super.initState();
    futureBudgetItems = fetchBudgetItems();
  }

  // Function to fetch data from the server (tbl_budgets)
  Future<List<BudgetItem>> fetchBudgetItems() async {
    String url =
        'https://slumberjer.com/mybudget/get_budgets.php'; // Replace with your endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': widget.userId.toString(), // Pass the userId for filtering
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => BudgetItem.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load budgets');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: Center(
        child: FutureBuilder<List<BudgetItem>>(
          future: futureBudgetItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].itemName),
                    subtitle: Text(
                      'Price: ${snapshot.data![index].itemPrice}\nDate: ${snapshot.data![index].itemDate}',
                    ),
                  );
                },
              );
            } else {
              return const Text('No data found');
            }
          },
        ),
      ),
    );
  }
}

// Model for a budget item
class BudgetItem {
  final int budgetId;
  final String itemName;
  final String itemPrice;
  final String budgetItemDesc;
  final String itemDate;

  BudgetItem({
    required this.budgetId,
    required this.itemName,
    required this.itemPrice,
    required this.budgetItemDesc,
    required this.itemDate,
  });

  // Factory constructor to create a BudgetItem from JSON
  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      budgetId: json['budget_id'],
      itemName: json['budget_itemName'],
      itemPrice: json['budget_itemPrice'],
      budgetItemDesc: json['budget_itemDesc'],
      itemDate: json['budget_itemDate'],
    );
  }
}
