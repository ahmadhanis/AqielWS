import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class NewBooking extends StatefulWidget {
  const NewBooking({super.key});

  @override
  State<NewBooking> createState() => _NewBookingState();
}

class _NewBookingState extends State<NewBooking> {
  var screenHeight, screenWidth;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController purposeController = TextEditingController();
  //var firstDate = DateTime.now();
  //var lastDate = DateTime.now().add(const Duration(days: 30));
  var formatter = DateFormat('dd-MM-yyyy');
  var selectedDate = DateTime.now();
  List<String> facilities = [];
  String dropdownvalue = "Dewan Asajaya";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadfacilities();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                loadfacilities();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
                child: Container(
                    padding: const EdgeInsets.all(16),
                    // height: screenHeight * 0.3,
                    child: Column(
                      children: [
                        const Text(
                          "Enter Your Details",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: idController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Staff ID/Matric',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: purposeController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Booking Purpose',
                          ),
                        ),
                      ],
                    ))),
            Card(
              child: Container(
                  padding: const EdgeInsets.all(8),
                  // height: 200,
                  width: screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Select Date",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2028))
                                .then((value) {
                              print(value);
                              setState(() {
                                selectedDate = value!;
                              });
                            });
                          },
                          icon: Icon(Icons.calendar_month)),
                      Text(formatter.format(selectedDate),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))
                    ],
                  )),
            ),
            Card(
                child: Container(
                    width: screenWidth,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Text("Select Facility"),
                        facilities.isEmpty
                            ? const Text("No Facility Available")
                            : Expanded(
                                child: Card(
                                  elevation: 3,
                                  child: DropdownButtonFormField<String>(
                                    value: dropdownvalue,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Facility',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.info),
                                    ),
                                    items: facilities.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownvalue = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                      ],
                    )))
          ],
        ),
      ),
    );
  }

  void loadfacilities() {
    facilities = [];
    http
        .get(Uri.parse(
            'https://ktarmarket.slumberjer.com/api/loadfacilities.php'))
        .then((response) {
      //log(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // print(data['data']['facility'].length);
          for (int i = 0; i < data['data']['facility'].length; i++) {
            facilities.add(data['data']['facility'][i]['facility_name']);
          }
          print(facilities);
          setState(() {});
        }
      }
    });
  }
}
