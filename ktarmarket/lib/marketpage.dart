import 'package:flutter/material.dart';
import 'package:ktarmarket/newitempage.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTAR Market'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text('KTAR Market'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewItemPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
