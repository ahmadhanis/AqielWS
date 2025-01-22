import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  double result = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text("MY App"),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: controller1,
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: controller2,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (controller1.text.isEmpty ||
                            controller2.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter a number")));
                          return;
                        }

                        double num1 = double.parse(controller1.text);
                        double num2 = double.parse(controller2.text);
                        result = num1 + num2;
                        setState(() {});
                      },
                      child: const Text("+")),
                  ElevatedButton(
                      onPressed: () {
                        if (controller1.text.isEmpty ||
                            controller2.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter a number")));
                          return;
                        }
                        double num1 = double.parse(controller1.text);
                        double num2 = double.parse(controller2.text);
                        result = num1 - num2;
                        setState(() {});
                      },
                      child: const Text("-")),
                  ElevatedButton(
                      onPressed: () {
                        if (controller1.text.isEmpty ||
                            controller2.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter a number")));
                          return;
                        }
                        double num1 = double.parse(controller1.text);
                        double num2 = double.parse(controller2.text);
                        result = num1 * num2;
                        setState(() {});
                      },
                      child: const Text("x")),
                  ElevatedButton(
                      onPressed: () {
                        if (controller1.text.isEmpty ||
                            controller2.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter a number")));
                          return;
                        }
                        double num1 = double.parse(controller1.text);
                        double num2 = double.parse(controller2.text);
                        result = num1 / num2;
                        setState(() {});
                      },
                      child: const Text("/")),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "RESULT:" + result.toString(),
                style: TextStyle(fontSize: 24),
              )
            ],
          ),
        ));
  }
}
