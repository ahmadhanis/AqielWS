import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktarmarket/newitempage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import 'item.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  //array of items object
  List<Item> itemList = <Item>[]; //list array objects
  String status = "Loading...";
  late double screenHeight, screenWidth;
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  void loadItems() {
    // TODO: implement loadItems
    http
        .get(Uri.parse('http://ktarmarket.slumberjer.com/api/loaditems.php'))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          itemList.clear();
          data['data']['items'].forEach((item) {
            print(data['data']['items']);
            itemList.add(Item(
                itemId: item['item_id'],
                email: item['email'],
                phone: item['phone'],
                itemName: item['item_name'],
                itemStatus: item['item_status'],
                itemDescription: item['item_description'],
                itemDate: item['item_date'],
                price: item['price']));
          });
          setState(() {
            status = "Loaded";
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTAR Market'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () {
              loadItems();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: itemList.isEmpty
          ? const Center()
          : ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      itemDetailsDialog(index);
                    },
                    leading: Image.network(
                        "http://ktarmarket.slumberjer.com/images/${itemList[index].itemId}.png"),
                    title: Text(itemList[index].itemName.toString()),
                    subtitle: Text(itemList[index].itemStatus.toString()),
                    trailing: Text(
                        "RM ${double.parse(itemList[index].price.toString()).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewItemPage()));
          loadItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void itemDetailsDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(itemList[index].itemName.toString()),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: screenHeight / 3,
                    width: screenWidth,
                    color: Colors.red,
                    child: Image.network(
                      "http://ktarmarket.slumberjer.com/images/${itemList[index].itemId}.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    itemList[index].itemDescription.toString(),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "RM ${double.parse(itemList[index].price.toString()).toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(df.format(
                          DateTime.parse(itemList[index].itemDate.toString()))),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(itemList[index].email.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(itemList[index].phone.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(itemList[index].itemStatus.toString()),
                    ],
                  ),
                  
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            launchUrlString('tel://${itemList[index].phone.toString()}');
                          },
                          icon: const Icon(
                            Icons.phone,
                            size: 40,
                          )),
                      IconButton(
                          onPressed: () {
                            launchUrlString('https://wa.me/${itemList[index].phone.toString()}');
                          },
                          icon: const Icon(
                            Icons.wechat,
                            size: 40,
                          )),
                      IconButton(
                          onPressed: () {
                            launchUrlString('mailto://${itemList[index].email.toString()}');
                          },
                          icon: const Icon(
                            Icons.email,
                            size: 40,
                          )),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'))
            ],
          );
        });
  }
}
