// ignore_for_file: use_build_context_synchronously

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportScreenYear extends StatefulWidget {
  final int userId; // Assuming userId is passed to filter data per user
  const ReportScreenYear({super.key, required this.userId});

  @override
  ReportScreenYearState createState() => ReportScreenYearState();
}

class ReportScreenYearState extends State<ReportScreenYear> {
  late int currentYear;
  late Future<List<dynamic>>
      futureYearlyReport; // Store the future for report data
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
  late int selectedYear;
  double totalYearSpending = 0.0;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  int adsno = 0;
  double? screenWidth, screenHeigth;
  @override
  void initState() {
    super.initState();
    // Get the current date
    DateTime now = DateTime.now();

    currentYear = now.year; // e.g., 2024
    selectedYear = currentYear;
    // Pass the month and year to fetchBudgetItems
    futureYearlyReport = fetchYearlyReport(selectedYear);
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8395142902989782/8916031052',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (ad is BannerAd) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchYearlyReport(int year) async {
    String url = 'https://slumberjer.com/mybudget/get_budgets_year.php';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'user_id': widget.userId.toString(),
        'year': year.toString(),
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      // Calculate total yearly spending
      totalYearSpending = 0.0; // Reset yearly spending
      for (var monthData in jsonResponse) {
        double monthSpending =
            double.tryParse(monthData['total_spending'].toString()) ?? 0.0;
        totalYearSpending += monthSpending;
      }
      setState(() {});

      return jsonResponse;
    } else {
      throw Exception('Failed to load yearly report');
    }
  }

  Future<void> showBarChartForYear(BuildContext context,
      List<Map<String, dynamic>> yearlyData, String year) {
    // Prepare data for bar chart
    List<BarChartGroupData> barChartGroups = [];
    for (var data in yearlyData) {
      int month = int.parse(data['month'].toString());
      double totalSpending = double.parse(data['total_spending'].toString());

      barChartGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: totalSpending,
              // color: Colors.blue, // You can use custom colors here
              width: 15,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    // Show the bar chart in a dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Spending for the Year $year'),
          content: SizedBox(
            height: screenHeigth,
            width: screenWidth,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text('RM${value.toStringAsFixed(0)}');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        List<String> months = [
                          '',
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        return Text(months[value.toInt()]);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                barGroups: barChartGroups,
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; //get screen width
    screenHeigth = MediaQuery.of(context).size.height / 1.5;
    if (screenWidth! > 600) {
      screenWidth = 600;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Report'),
      ),
      body: Center(
          child: SizedBox(
        width: screenWidth,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    futureYearlyReport = fetchYearlyReport(selectedYear);
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
            child: FutureBuilder<List<dynamic>>(
              future: futureYearlyReport, // Use the future stored in initState
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        const SizedBox(height: 8.0),
                        if (_isBannerAdReady)
                          SizedBox(
                            height: _bannerAd.size.height.toDouble(),
                            width: screenWidth,
                            child: AdWidget(ad: _bannerAd),
                          )
                      ],
                    ),
                  );
                } else {
                  List<dynamic> reportData = snapshot.data!;

                  return ListView.builder(
                    itemCount: reportData.length,
                    itemBuilder: (context, index) {
                      // Extract month, total spending, and item count from the data
                      int month =
                          int.parse(reportData[index]['month'].toString());
                      double totalSpending = double.parse(
                          reportData[index]['total_spending'].toString());
                      int itemCount =
                          int.parse(reportData[index]['item_count'].toString());

                      // Format the month into readable string (e.g., "January")
                      String monthName = getMonthName(month);

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(monthName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Total Spending: RM ${totalSpending.toStringAsFixed(2)}\n'
                            'Total Items: $itemCount\n',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
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
                  'Total Yearly Spending', // Label text
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white70, // Lighter color for label
                  ),
                ),
                Text(
                  'RM ${totalYearSpending.toStringAsFixed(2)}', // Displaying the total spending
                  style: const TextStyle(
                    fontSize: 24.0, // Bigger font for the total spending value
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for modern contrast
                  ),
                ),
              ],
            ),
          )
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchYearlyReport(selectedYear).then((List<dynamic> items) {
            // Now you have a List<BudgetItem>
            if (items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No data available')),
              );
              return;
            }

            // Ensure that items are cast to List<Map<String, dynamic>>
            List<Map<String, dynamic>> parsedItems = items.map((item) {
              return Map<String, dynamic>.from(item); // Cast each item properly
            }).toList();

            showBarChartForYear(context, parsedItems, selectedYear.toString());
          }).catchError((error) {
            // Handle any error that occurred while fetching the items
          });
        },
        child: const Icon(Icons.bar_chart),
      ),
    );
  }

  // Helper method to get month name from month number
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
}

class YearBudgetItem {
  int? month;
  double? totalSpending;
  String? itemCount;

  YearBudgetItem({this.month, this.totalSpending, this.itemCount});

  YearBudgetItem.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    totalSpending = json['total_spending'];
    itemCount = json['item_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['month'] = month;
    data['total_spending'] = totalSpending;
    data['item_count'] = itemCount;
    return data;
  }
}
