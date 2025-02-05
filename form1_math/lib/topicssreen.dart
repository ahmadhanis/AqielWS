import 'package:flutter/material.dart';
import 'package:form1_math/topic2/factormenu.dart';
import 'package:form1_math/topic3/powerrootmenu.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({Key? key}) : super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  // Define the topics with title, subtitle, and icon.
  final List<Map<String, String>> topics = [
    {
      'title': 'Topic 1',
      'subtitle': 'Fractions',
    },
    {
      'title': 'Topic 2',
      'subtitle': 'Factors and Multiples',
    },
    {
      'title': 'Topic 3',
      'subtitle': 'Square and Roots',
    },
    {
      'title': 'Topic 4',
      'subtitle': 'Algebra',
    },
        {
      'title': 'Topic 5',
      'subtitle': 'Linear',
    },
        {
      'title': 'Topic 6',
      'subtitle': 'Perimeter and Area',
    },
        {
      'title': 'Topic 7',
      'subtitle': 'Pythagoras Theorem',
    },
  ];

  // Define a list of icons corresponding to the topics.
  final List<IconData> topicIcons = [
    Icons.looks_one,
    Icons.calculate,
    Icons.looks_3,
    Icons.looks_4,
    Icons.looks_5,
    Icons.looks_6,
    Icons.numbers,

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form 1 Math'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: topics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // Adjusted aspect ratio for extra vertical space
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final topic = topics[index];
            return GestureDetector(
              onTap: () {
                // Provided navigation behavior: For Topic 2, navigate to FactorMenu.
                if (index == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Coming soon!'),
                    ),
                  );
                }
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FactorMenu(),
                    ),
                  );
                }
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PowerRootMenu(),
                    ),
                  );
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Use MainAxisSize.min to prevent the Column from taking up excess space.
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        topicIcons[index],
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        topic['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          topic['subtitle']!,
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
