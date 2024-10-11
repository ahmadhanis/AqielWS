// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBudget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyBudgetPage(title: 'MyBudget'),
    );
  }
}

class MyBudgetPage extends StatefulWidget {
  const MyBudgetPage({super.key, required this.title});

  final String title;

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
    'Others',
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double? screenWidth, screenHeigth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime selectedDate = DateTime.now(); //get current date
    var formatter = DateFormat('dd-MM-yyyy hh:mm a'); //date format
    String formattedDate = formatter.format(selectedDate); //format date
    itemDateController.text = formattedDate.toString();
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: screenWidth,
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.abc),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: DropdownButton(
                          itemHeight: 80,
                          isExpanded: true,
                          value: dropdownvalue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue!;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.attach_money),
                        hintText: "Enter Item Price"),
                    keyboardType: TextInputType.number,
                    controller: itemPriceController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030))
                          .then((selectedDate) {
                        if (selectedDate != null) {
                          showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                              .then((selectTime) {
                            if (selectTime != null) {
                              DateTime selectedDateTime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectTime.hour,
                                selectTime.minute,
                              );
                              // print(selectedDateTime);
                              var formatter = DateFormat('dd-MM-yyyy hh:mm a');
                              String formattedDate =
                                  formatter.format(selectedDateTime);
                              itemDateController.text =
                                  formattedDate.toString();
                              setState(() {}); //refresh screen with new data
                            }
                          });
                        }
                      });
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.calendar_today),
                        hintText: "Enter Item Date"),
                    controller: itemDateController,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.info),
                        hintText: "Enter Item Description"),
                    controller: itemDescController,
                    maxLines: 5,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  MaterialButton(
                      minWidth: screenWidth,
                      height: 50,
                      color: Colors.yellow,
                      onPressed: insertData,
                      child: const Text("Insert")),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> insertData() async {
    const snackBar = SnackBar(
      content: Text('Please enter price'),
    ); //snackbar object
    String itemName = dropdownvalue; //get item name

    if (itemPriceController.text.isEmpty) {
      //check if price is empty
      ScaffoldMessenger.of(context).showSnackBar(snackBar); //show snackbar
      return;
    }
    double itemPrice = double.parse(itemPriceController.text); //get item price
    String itemDate = itemDateController.text; //get item date
    String itemDesc = itemDescController.text; //get item description

    Map<String, String> data = {
      'item_name': itemName,
      'item_price': itemPrice.toString(),
      'item_date': itemDate,
      'item_desc': itemDesc
    };

    String url = 'https://slumberjer.com/mybudget/insert.php';
    //String url = 'http://localhost/mybudget/insert.php';
    try {
      // Send the POST request with the data
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );
      print(response.body);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data inserted successfully')),
          );
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
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred')),
      );
    }
  }
}
