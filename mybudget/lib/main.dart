import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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
  double? screenWidth;

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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Container(
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
                                context: context, initialTime: TimeOfDay.now())
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
                            itemDateController.text = formattedDate.toString();
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

                MaterialButton(
                    minWidth: screenWidth,
                    color: Colors.yellow,
                    onPressed: insertData,
                    child: const Text("Insert")),
                // ElevatedButton(onPressed: insertData, child: const Text("Insert"))
              ],
            ),
          ),
        ));
  }

  void insertData() {
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

    setState(() {}); //update the state
    print("Item Name: $itemName");
    print("Item Price: $itemPrice");
    print("Item Date: $itemDate");
  }
}
