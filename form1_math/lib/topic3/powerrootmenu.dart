import 'package:flutter/material.dart';
import 'package:form1_math/topic3/cuberootscreen.dart';
import 'package:form1_math/topic3/squarerootscreen.dart';

class PowerRootMenu extends StatefulWidget {
  const PowerRootMenu({Key? key}) : super(key: key);

  @override
  State<PowerRootMenu> createState() => _PowerRootMenuState();
}

class _PowerRootMenuState extends State<PowerRootMenu> {
  // Define the menu items for the screen.
  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Square and Root",
      "subtitle": "Square calculator",
      "icon": Icons.calculate,
      "screen": const SquareRootScreen(),
    },
    {
      "title": "Cube and Root",
      "subtitle": "Cube calculator",
      "icon": Icons.functions,
      "screen": const CubeRootScreen(), // No screen provided.
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Square and Root Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            // shrinkWrap is set to true so the GridView doesn't try to expand
            // unnecessarily beyond the available space.
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
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
                  // If a screen is provided, navigate to it.
                  if (item["screen"] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => item["screen"],
                      ),
                    );
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item["icon"],
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item["title"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item["subtitle"],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
