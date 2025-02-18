import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ktarmarket/booking/bookingslot.dart';
import 'package:ktarmarket/booking/facility.dart';

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
  var formatter2 = DateFormat('dd/MM/yyyy');

  var selectedDate = DateTime.now();
  List<String> facilities = [];
  List<Facility> facilityList = <Facility>[];
  Facility selectedFac = Facility();
  List<BookingSlot> slotList = <BookingSlot>[];
  List<int> TimeSlot = [0, 0, 0, 0, 0, 0, 0, 0, 0];

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
                                        if (facilityList.isNotEmpty) {
                                          for (int i = 0;
                                              i < facilityList.length;
                                              i++) {
                                            if (facilityList[i].facilityName ==
                                                dropdownvalue) {
                                              selectedFac = facilityList[i];
                                              loadSlot(selectedFac.facilityId,
                                                  selectedDate);
                                            }
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                      ],
                    ))),
            selectedFac.facilityId == null
                ? Card(
                    child: Container(
                        width: screenWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text("Please select a facility")))
                : Card(
                    child: Container(
                        width: screenWidth,
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          Text(selectedFac.facilityName.toString()),
                          Text(selectedFac.facilityPic.toString()),
                          Text(selectedFac.facilityType.toString()),
                        ]))),
            slotList.isEmpty
                ? Card(
                    child: Container(
                        width: screenWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text("No Time Slot available")))
                : Card(
                    child: Container(
                        width: screenWidth,
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          Text("Select Available Time Slot"),
                          Column(
                            children: [
                              Text(TimeSlot[0].toString()),
                              Text(TimeSlot[1].toString()),
                              Text(TimeSlot[2].toString()),
                              Text(TimeSlot[3].toString()),
                              Text(TimeSlot[4].toString()),
                              Text(TimeSlot[5].toString()),
                              Text(TimeSlot[6].toString()),
                              Text(TimeSlot[7].toString()),
                              Text(TimeSlot[8].toString()),
                            ],
                          )
                        ]))),
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
      // log(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // log(data);
        if (data['status'] == 'success') {
          // print(data['data']['facility'].length);
          for (int i = 0; i < data['data']['facility'].length; i++) {
            facilities.add(data['data']['facility'][i]['facility_name']);
          }
          facilityList.clear();
          data['data']['facility'].forEach((fac) {
            Facility t = Facility.fromJson(fac);
            facilityList.add(t);
            // print(t.facilityName);
          });

          //print(facilities);
          setState(() {});
        }
      }
    });
  }

  void loadSlot(String? facilityId, DateTime selectedDate) {
    TimeSlot = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    String selectedDateStr = formatter2.format(selectedDate);
    //print(selectedDateStr);
    http
        .get(Uri.parse(
            'https://ktarmarket.slumberjer.com/api/loadslots.php?facility_id=$facilityId&booking_date=$selectedDateStr'))
        .then((response) {
      //print(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          slotList.clear();
          data['data'].forEach((slot) {
            BookingSlot t = BookingSlot.fromJson(slot);
            slotList.add(t);
            if (t.slot8 == "1" && TimeSlot[0] == 0) {
              TimeSlot[0] = 1;
            }
            if (t.slot9 == "1" && TimeSlot[1] == 0) {
              TimeSlot[1] = 1;
            }
            if (t.slot10 == "1" && TimeSlot[2] == 0) {
              TimeSlot[2] = 1;
            }
            if (t.slot11 == "1" && TimeSlot[3] == 0) {
              TimeSlot[3] = 1;
            }
            if (t.slot12 == "1" && TimeSlot[4] == 0) {
              TimeSlot[4] = 1;
            }
            if (t.slot13 == "1" && TimeSlot[5] == 0) {
              TimeSlot[5] = 1;
            }
            if (t.slot14 == "1" && TimeSlot[6] == 0) {
              TimeSlot[6] = 1;
            }
            if (t.slot15 == "1" && TimeSlot[7] == 0) {
              TimeSlot[7] = 1;
            }
            if (t.slot16 == "1" && TimeSlot[8] == 0) {
              TimeSlot[8] = 1;
            }
            if (t.slot17 == "1" && TimeSlot[9] == 0) {
              TimeSlot[9] = 1;
            }
          });
          print(TimeSlot);
          setState(() {});
        }
      }
    });
  }
}
