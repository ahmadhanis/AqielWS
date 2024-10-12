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
  late String currentMonth, currentYear;
  @override
  void initState() {
    super.initState();
    // Get the current date
    DateTime now = DateTime.now();

    // Extract the current month and year in number format
    currentMonth = now.month.toString(); // e.g., 10 for October
    currentYear = now.year.toString(); // e.g., 2024

    // Pass the month and year to fetchBudgetItems
    futureBudgetItems = fetchBudgetItems(currentMonth, currentYear);
  }

  // Function to fetch data from the server (tbl_budgets)
  Future<List<BudgetItem>> fetchBudgetItems(String month, String year) async {
    print(month + "/" + year);
    String url =
        'https://slumberjer.com/mybudget/get_budgets.php'; // Replace with your endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': widget.userId.toString(), // Pass the userId for filtering
          'month': month.toString(), // Pass the current month
          'year': year.toString(), // Pass the current year
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
          child: Column(
        children: [
          Row(
            children: [
              Text("Month: " + currentMonth.toString()),
              Text("Year: " + currentYear.toString())
            ],
          ),
          Expanded(
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
                          'Desc: ${snapshot.data![index].itemDesc} \nPrice: RM ${snapshot.data![index].itemPrice}\nDate: ${snapshot.data![index].itemDate}',
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
        ],
      )),
    );
  }
}

// Model for a budget item
class BudgetItem {
  final int budgetId;
  final String itemName;
  final String itemPrice;
  final String itemDesc;
  final String itemDate;

  BudgetItem({
    required this.budgetId,
    required this.itemName,
    required this.itemPrice,
    required this.itemDesc,
    required this.itemDate,
  });

  // Factory constructor to create a BudgetItem from JSON
  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      budgetId: json['budget_id'],
      itemName: json['budget_itemName'],
      itemPrice: json['budget_itemPrice'],
      itemDesc: json['budget_itemDesc'],
      itemDate: json['budget_itemDate'],
    );
  }
}
