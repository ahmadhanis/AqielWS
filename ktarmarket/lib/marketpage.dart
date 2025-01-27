import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ktarmarket/newitempage.dart';
import 'package:http/http.dart' as http;

import 'item.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  //array of items object
  List<Item> itemList = <Item>[];
  String status = "Loading...";

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
                    onTap: () {},
                    leading: Image.network(
                        "http://ktarmarket.slumberjer.com/images/${itemList[index].itemId}.png"),
                    title: Text(itemList[index].itemName.toString()),
                    subtitle: Text(itemList[index].itemDescription.toString()),
                    trailing: Text(
                        "RM ${double.parse(itemList[index].price.toString()).toStringAsFixed(2)}"),
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
}
