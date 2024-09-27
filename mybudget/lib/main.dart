import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Item Name"),
              TextField(
                controller: itemNameController,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Item Price"),
              TextField(
                controller: itemPriceController,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Item Date"),
              TextField(
                controller: itemDateController,
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                  minWidth: 300,
                  color: Colors.yellow,
                  onPressed: insertData,
                  child: const Text("Insert")),
              // ElevatedButton(onPressed: insertData, child: const Text("Insert"))
            ],
          ),
        ));
  }

  void insertData() {
    String itemName = itemNameController.text;
    double itemPrice = double.parse(itemPriceController.text);
    String itemDate = itemDateController.text;

    print("Item Name: $itemName");
    print("Item Price: $itemPrice");
    print("Item Date: $itemDate");
  }
}
