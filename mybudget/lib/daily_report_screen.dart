// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mybudget/feedback_screen.dart';
import 'package:mybudget/montly_report_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBudgetPage extends StatefulWidget {
  const MyBudgetPage({super.key, required this.title, required this.userId});

  final String title;
  final int userId;

  @override
  State<MyBudgetPage> createState() => _MyBudgetPageState();
}

class _MyBudgetPageState extends State<MyBudgetPage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemDateController = TextEditingController();
  TextEditingController itemDescController = TextEditingController();

  String dropdownvalue = 'Breakfast';
  var items = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Groceries',
    'Travel',
    'Others',
  ];
  //get user id
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double? screenWidth, screenHeigth;
  double totalDaySpending = 0.0;
  late Future<List<BudgetItem>> futureBudgetItems;
  late String currentDay, currentMonth, currentYear;
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  final List<int> days =
      List.generate(31, (index) => index + 1); // [1, 2, 3, ..., 12]
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

  @override
  void initState() {
    super.initState();
    DateTime selectedDate = DateTime.now(); //get current date
    var formatter = DateFormat('dd-MM-yyyy hh:mm a'); //date format
    String formattedDate = formatter.format(selectedDate); //format date
    DateTime now = DateTime.now();

    currentDay = now.day.toString();
    currentMonth = now.month.toString(); // e.g., 10 for October
    currentYear = now.year.toString(); // e.g., 2024
    selectedDay = int.parse(currentDay);
    selectedMonth = int.parse(currentMonth);
    selectedYear = int.parse(currentYear);

    itemDateController.text = formattedDate.toString();

    futureBudgetItems = fetchBudgetItems(currentDay, currentMonth, currentYear);
  }

  Future<List<BudgetItem>> fetchBudgetItems(
      String day, String month, String year) async {
    totalDaySpending = 0.0;
    String url =
        'https://slumberjer.com/mybudget/get_budgets_day.php'; // Replace with your endpoint
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': widget.userId.toString(), // Pass the userId for filtering
          'day': day.toString(), // Pass the current day.
          'month': month.toString(), // Pass the current month
          'year': year.toString(), // Pass the current year
        },
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        // Calculate total monthly spending

        List<BudgetItem> items = jsonResponse.map((data) {
          BudgetItem item = BudgetItem.fromJson(data);

          // Parse the price and add to totalSpending
          totalDaySpending += double.tryParse(item.itemPrice) ?? 0.0;

          return item;
        }).toList();

        // Update the state with the calculated total spending
        setState(() {
          //totalDaySpending = totalSpending;
        });

        return items;
      } else {
        throw Exception('Failed to load budgets');
      }
    } catch (e) {
      return [];
    }
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  void showInsertDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: const Text('Insert New Item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown section
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: const Icon(
                        Icons.category, // Icon before the dropdown
                      ),
                    ),
                    isExpanded: true,
                    value: dropdownvalue,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      dropdownvalue = newValue!; // Update the dropdown value
                    },
                  ),

                  const SizedBox(height: 10),

                  // Item Price TextField
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Enter Item Price",
                      labelStyle: const TextStyle(),
                      prefixIcon: const Icon(
                        Icons.attach_money,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    keyboardType: TextInputType.number,
                    controller: itemPriceController,
                  ),
                  const SizedBox(height: 10),

                  // Item Date TextField
                  TextField(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      ).then((selectedDate) {
                        if (selectedDate != null) {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          ).then((selectTime) {
                            if (selectTime != null) {
                              DateTime selectedDateTime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectTime.hour,
                                selectTime.minute,
                              );
                              var formatter = DateFormat('dd-MM-yyyy hh:mm a');
                              String formattedDate =
                                  formatter.format(selectedDateTime);
                              itemDateController.text =
                                  formattedDate.toString();
                            }
                          });
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      labelStyle: const TextStyle(),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    controller: itemDateController,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 10),

                  // Item Description TextField
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Enter Item Description",
                      labelStyle: const TextStyle(),
                      prefixIcon: const Icon(
                        Icons.description,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    controller: itemDescController,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 25),

                  // Insert Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        insertData(); // Insert the data
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Insert",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                futureBudgetItems =
                    fetchBudgetItems(currentDay, currentMonth, currentYear);
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

  Future<void> shareBudgetItemsViaWhatsApp(
      BuildContext context, String day, String month, String year) async {
    // Fetch the budget items first
    List<BudgetItem> items = await fetchBudgetItems(day, month, year);

    if (items.isEmpty) {
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
    message.writeln('My Budget for $day-$month-$year:');
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; // get screen width
    screenHeigth = MediaQuery.of(context).size.height / 1.5;
    if (screenWidth! > 600) {
      screenWidth = 600;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Daily Report"),

        // Add actions for dropdown menu
        actions: [
          IconButton(
              tooltip: "Montly Report",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              icon: const Icon(Bootstrap.calendar2)),
          IconButton(
              tooltip: "Share via WhatsApp",
              onPressed: () {
                shareBudgetItemsViaWhatsApp(context, selectedDay.toString(),
                    selectedMonth.toString(), selectedYear.toString());
              },
              icon: const Icon(FontAwesome.whatsapp_brand)),
          IconButton(
              tooltip: "About App",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('About App'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/aqiel.png',
                              width: 200, height: 200),
                          const SizedBox(height: 10),
                          const Text(
                            "M. Aqiel Akhtar, IPGKTAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'This is a simple app to help you manage your budget. It allows you to add, view, edit and delete budget items. The app provide daily, montly and yearly report. You can also share your budget via WhatsApp.',
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Version: 1.0.0',
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedBackScreen(
                                      userId: widget
                                          .userId, // Pass the userId to MyBudgetPage
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Feedback',
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Bootstrap.info_circle)),
        ],
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
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Day',
                        labelStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      value: selectedDay, // Set default value to current month
                      items: days.map((int day) {
                        return DropdownMenuItem<int>(
                          value: day,
                          child:
                              Text(day.toString()), // Display month as a number
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedDay = newValue!;
                        });
                      },
                      hint: const Text('Day'),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Dropdown for month
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Month',
                        labelStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      value:
                          selectedMonth, // Set default value to current month
                      items: months.map((int month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(
                              month.toString()), // Display month as a number
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
                  const SizedBox(width: 2), // Spacing between dropdowns

                  // Dropdown for year
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: const TextStyle(fontSize: 12),
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
                        selectedDay.toString(),
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
                            deleteBudgetDialog(context,
                                item.budgetId.toString(), item.itemName);
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
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 400, // Set maximum width here
                                    ),
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0), // Rounded button corners
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                  ),
                                );
                              },
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4, // Adds shadow to the card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Rounded corners
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
                            'No data found.\nAdd new entry using the floating button below.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade600, // Softer color for modern look
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                    'Total Spending for the Day', // Label text
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70, // Lighter color for label
                    ),
                  ),
                  Text(
                    'RM ${totalDaySpending.toStringAsFixed(2)}', // Displaying the total spending
                    style: const TextStyle(
                      fontSize:
                          24.0, // Bigger font for the total spending value
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for modern contrast
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showInsertDataDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> insertData() async {
    const snackBar = SnackBar(
      content: Text('Incorrect price input!'),
    ); //snackbar object
    String itemName = dropdownvalue; //get item name

    if (itemPriceController.text.isEmpty) {
      //check if price is empty
      ScaffoldMessenger.of(context).showSnackBar(snackBar); //show snackbar
      return;
    }
    // Check if the price entered is a valid number
    if (double.tryParse(itemPriceController.text) == null) {
      itemPriceController.text = "";
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    double itemPrice = double.parse(itemPriceController.text); //get item price
    String itemDate = itemDateController.text; //get item date
    String itemDesc = itemDescController.text; //get item description

    // Confirmation Dialog before proceeding
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Data Insertion"),
          content:
              Text("Are you sure you want to insert the following item?\n\n"
                  "Item Name: $itemName\n"
                  "Price: $itemPrice\n"
                  "Date: $itemDate\n"
                  "Description: $itemDesc"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    // If the user did not confirm, do not proceed
    if (confirmed != true) {
      return;
    }

    // Proceed with inserting data after confirmation
    Map<String, String> data = {
      'user_id': widget.userId.toString(),
      'item_name': itemName,
      'item_price': itemPrice.toString(),
      'item_date': itemDate,
      'item_desc': itemDesc
    };

    String url = 'https://slumberjer.com/mybudget/insert.php';

    try {
      // Send the POST request with the data
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          Navigator.of(context).pop(true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data inserted successfully')),
          );

          futureBudgetItems =
              fetchBudgetItems(currentDay, currentMonth, currentYear);
          setState(() {
            itemPriceController.text = "";
            // itemDateController.text = "";
            itemDescController.text = "";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to insert data')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred')),
      );
    }
  }
}
