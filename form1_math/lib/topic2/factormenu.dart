import 'package:flutter/material.dart';
import 'package:form1_math/topic2/commonfactor.dart';
import 'package:form1_math/topic2/factorcalculator.dart';
import 'package:form1_math/topic2/multiplescreen.dart';
import 'package:form1_math/topic2/primefactorcalculator.dart';

class FactorMenu extends StatefulWidget {
  const FactorMenu({super.key});

  @override
  State<FactorMenu> createState() => _FactorMenuState();
}

class _FactorMenuState extends State<FactorMenu> {
  // Define the menu items with title, subtitle, icon, and the corresponding screen widget.
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Factors',
      'subtitle': 'Factor of a number',
      'icon': Icons.functions,
      'screen': const FactorCalculator(),
    },
    {
      'title': 'Prime Factors',
      'subtitle': 'Find prime factors',
      'icon': Icons.filter_1,
      'screen': PrimeFactorCalculator(),
    },
    {
      'title': 'Common Factors',
      'subtitle': 'Determine common factors',
      'icon': Icons.all_inbox,
      'screen': const CommonFactorScreen(),
    },
    {
      'title': 'Multiple',
      'subtitle': 'Calculate multiples',
      'icon': Icons.exposure_plus_1,
      'screen': const MultipleScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factors & Multiple Menu'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        // Use GridView.builder for a modern grid-based layout.
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row.
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9, // Adjust for a balanced card height.
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                // Use provided navigation to push the corresponding screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['screen']),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          item['subtitle'],
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
