// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mybudget/report_screen_year.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  final int userId; // Assuming userId is passed to filter data per user
  const ReportScreen({super.key, required this.userId});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  late Future<List<BudgetItem>> futureBudgetItems;
  late String currentMonth, currentYear;
  final List<int> months =
      List.generate(12, (index) => index + 1); // [1, 2, 3, ..., 12]
  final List<int> years = [
    2024,
    2025,
    2026,
    2027,
    2028,
    2029,
    2030
  ]; // [2024, 2025, ..., 2030]
  late int selectedMonth;
  late int selectedYear;
  double totalMonthSpending = 0.0;

  double? screenWidth, screenHeigth;
  @override
  void initState() {
    super.initState();
    // Get the current date
    DateTime now = DateTime.now();

    // Extract the current month and year in number format
    currentMonth = now.month.toString(); // e.g., 10 for October
    currentYear = now.year.toString(); // e.g., 2024
    selectedMonth = int.parse(currentMonth);
    selectedYear = int.parse(currentYear);
    // Pass the month and year to fetchBudgetItems
    futureBudgetItems = fetchBudgetItems(currentMonth, currentYear);
  }

  // Function to fetch data from the server (tbl_budgets)
  Future<List<BudgetItem>> fetchBudgetItems(String month, String year) async {
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

        // Calculate total monthly spending
        double totalSpending = 0.0;

        List<BudgetItem> items = jsonResponse.map((data) {
          BudgetItem item = BudgetItem.fromJson(data);

          // Parse the price and add to totalSpending
          totalSpending += double.tryParse(item.itemPrice) ?? 0.0;

          return item;
        }).toList();

        // Update the state with the calculated total spending
        setState(() {
          totalMonthSpending = totalSpending;
        });

        return items;
      } else {
        throw Exception('Failed to load budgets');
      }
    } catch (e) {
      print('Error occurred: $e');
      return [];
    }
  }

  String getMonthName(int monthNumber) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[monthNumber - 1]; // Month number is 1-based
  }

  Future<void> shareBudgetItemsViaWhatsApp(
      BuildContext context, String month, String year) async {
    // Fetch the budget items first
    List<BudgetItem> items = await fetchBudgetItems(month, year);

    if (items.isEmpty) {
      print('No budget items to share.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No budget items to share.')),
      );
      return;
    }

    /// If WhatsApp cannot be launched, a SnackBar will be shown with a message
    /// indicating that WhatsApp could not be launched.
    ///
    /// The [BuildContext] is used to show the confirmation dialog and SnackBars.
    // Prepare the message
    StringBuffer message = StringBuffer();
    message.writeln('My Budget for $month-$year:');
    message.writeln('--------------------------------');

    double totalSpending = 0.0;

    for (var item in items) {
      message.writeln('Item: ${item.itemName}');
      message.writeln('Description: ${item.itemDesc}');
      message.writeln('Price: RM ${item.itemPrice}');
      message.writeln('Date: ${item.itemDate}');
      message.writeln('--------------------------------');
      totalSpending += double.tryParse(item.itemPrice) ?? 0.0;
    }

    message.writeln('Total Spending: RM ${totalSpending.toStringAsFixed(2)}');

    // Encode the message to be URL-friendly
    String encodedMessage = Uri.encodeComponent(message.toString());

    // WhatsApp sharing URL
    String whatsappUrl = "https://wa.me/?text=$encodedMessage";

    // Show a confirmation dialog asking if the user wants to share via WhatsApp
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share via WhatsApp'),
          content: const Text(
              'Are you sure you want to share your budget via WhatsApp?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog if cancelled
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog before sharing

                // Check if WhatsApp can be opened
                if (await canLaunch(whatsappUrl)) {
                  await launch(whatsappUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch WhatsApp')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(),
              child: const Text(
                'Share',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  Future<void> showPieChartForMonth(
      BuildContext context, List<BudgetItem> budgetItems, String month) {
    // Calculate total price for each item category
    Map<String, double> categoryTotals = {
      'Breakfast': 0.0,
      'Lunch': 0.0,
      'Dinner': 0.0,
      'Groceries': 0.0,
      'Others': 0.0,
    };

    for (var item in budgetItems) {
      if (categoryTotals.containsKey(item.itemName)) {
        // Ensure that categoryTotals[item.itemName] is not null before adding
        categoryTotals[item.itemName] = (categoryTotals[item.itemName] ?? 0.0) +
            (double.tryParse(item.itemPrice) ?? 0.0);
      } else {
        // Add to 'Others' category and ensure that value is not null
        categoryTotals['Others'] = (categoryTotals['Others'] ?? 0.0) +
            (double.tryParse(item.itemPrice) ?? 0.0);
      }
    }

    // Prepare data for pie chart
    List<PieChartSectionData> pieChartSections = [];
    categoryTotals.forEach((category, total) {
      pieChartSections.add(
        PieChartSectionData(
          value: total,
          title: '$category\nRM ${total.toStringAsFixed(2)}',
          color: getColorForCategory(
              category), // Optional: Use custom colors for each category
          radius: 80,
        ),
      );
    });

    // Show the pie chart in a dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Spending Breakdown for $month'),
          content: SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Helper method to get custom colors for each category
  Color getColorForCategory(String category) {
    switch (category) {
      case 'Breakfast':
        return Colors.blue;
      case 'Lunch':
        return Colors.green;
      case 'Dinner':
        return Colors.orange;
      case 'Groceries':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> deleteBudgetDialog(
      BuildContext context, String itemId, String itemName) async {
    bool isDeleted = false; // Track whether the deletion was successful

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close the confirmation dialog before starting async operation

                // Call the delete API
                String url = 'https://slumberjer.com/mybudget/delete.php';
                try {
                  final response = await http.post(
                    Uri.parse(url),
                    body: {
                      'item_id': itemId, // Pass the item ID to the backend
                    },
                  );

                  if (response.statusCode == 200) {
                    isDeleted =
                        true; // Set flag to true if deletion was successful
                  } else {
                    isDeleted = false; // Deletion failed
                  }
                } catch (e) {
                  isDeleted = false; // Network or other error
                }

                // After async operation, show the result using the mounted context
                if (isDeleted) {
                  showSnackBar(context, 'Item deleted successfully');
                } else {
                  showSnackBar(context, 'Failed to delete the item');
                }
                Navigator.of(context).pop();
                futureBudgetItems = fetchBudgetItems(currentMonth, currentYear);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color for delete
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSnackBar(BuildContext context, String message) {
    // Ensure this is called only while the widget is still active
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; //get screen width
    screenHeigth = MediaQuery.of(context).size.height / 1.5;
    if (screenWidth! > 600) {
      screenWidth = 600;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montly Report'),
        actions: [
          IconButton(
              onPressed: () {
                fetchBudgetItems(
                        selectedMonth.toString(), selectedYear.toString())
                    .then((List<BudgetItem> items) {
                  // Now you have a List<BudgetItem>
                  if (items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No data available')),
                    );
                    return;
                  }
                  showPieChartForMonth(
                      context, items, getMonthName(selectedMonth));
                }).catchError((error) {
                  // Handle any error that occurred while fetching the items
                  print('Error: $error');
                });
              },
              icon: const Icon(Icons.pie_chart)),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReportScreenYear(userId: widget.userId)),
                );
              },
              icon: const Icon(Icons.calendar_month)),
          IconButton(
              onPressed: () {
                shareBudgetItemsViaWhatsApp(
                    context, selectedMonth.toString(), selectedYear.toString());
              },
              icon: const Icon(Icons.share))
        ],
      ),
      body: Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dropdown for month
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Month',
                      labelStyle: const TextStyle(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    value: selectedMonth, // Set default value to current month
                    items: months.map((int month) {
                      return DropdownMenuItem<int>(
                        value: month,
                        child:
                            Text(month.toString()), // Display month as a number
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedMonth = newValue!;
                      });
                    },
                    hint: const Text('Month'),
                  ),
                ),
                const SizedBox(width: 5), // Spacing between dropdowns

                // Dropdown for year
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Year',
                      labelStyle: const TextStyle(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    value: selectedYear, // Set default value to current year
                    items: years.map((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()), // Display year
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                      });
                    },
                    hint: const Text('Year'),
                  ),
                ),
                const SizedBox(width: 5), // Spacing before the search button

                // Search button
                ElevatedButton(
                  onPressed: () {
                    futureBudgetItems = fetchBudgetItems(
                      selectedMonth.toString(),
                      selectedYear.toString(),
                    );
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    // Modern button color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BudgetItem>>(
              future: futureBudgetItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator()],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];

                      return GestureDetector(
                        onLongPress: () {
                          deleteBudgetDialog(
                              context, item.budgetId.toString(), item.itemName);
                        },
                        onTap: () {
                          // Show dialog window with item details
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Rounded corners
                                ),
                                elevation: 10,
                                backgroundColor: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      20.0), // Padding inside the dialog
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title of the dialog
                                      Text(
                                        item.itemName,
                                        style: const TextStyle(
                                          fontSize:
                                              22.0, // Larger font for modern feel
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              15.0), // Space between title and content
                                      // Description
                                      Text(
                                        'Description: ${item.itemDesc}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      // Price
                                      Text(
                                        'Price: RM ${item.itemPrice}',
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      // Date
                                      Text(
                                        'Date: ${item.itemDate}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              20.0), // Space before the actions
                                      // Actions row
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.0), // Rounded button corners
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24.0,
                                              vertical: 12.0,
                                            ),
                                          ),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                              color: Colors
                                                  .white, // Button text color
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4, // Adds shadow to the card
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15.0), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                                16.0), // Padding inside the card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item name (bold and larger font size)
                                Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                    height: 8.0), // Spacing between elements
                                // Item description
                                Text(
                                  'Description: ${truncateString(item.itemDesc, 50)}',
                                  style: const TextStyle(
                                      fontSize: 14.0, color: Colors.grey),
                                ),
                                const SizedBox(height: 8.0),
                                // Price and Date in a row layout
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Price
                                    Text(
                                      'Price: RM ${item.itemPrice}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    // Date
                                    Text(
                                      item.itemDate,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(
                        20.0), // Padding inside the container
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 50,
                          // Modern color for the icon
                        ),
                        const SizedBox(
                            height: 20), // Spacing between icon and text
                        Text(
                          'No data found',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .grey.shade600, // Softer color for modern look
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              // Background color for modern feel
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Soft shadow effect
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Total Spending for the Month', // Label text
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white70, // Lighter color for label
                  ),
                ),
                Text(
                  'RM ${totalMonthSpending.toStringAsFixed(2)}', // Displaying the total spending
                  style: const TextStyle(
                    fontSize: 24.0, // Bigger font for the total spending value
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for modern contrast
                  ),
                ),
              ],
            ),
          )
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
