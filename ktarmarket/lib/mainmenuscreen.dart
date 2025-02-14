import 'package:flutter/material.dart';
import 'package:ktarmarket/booking/bookingpage.dart';
import 'package:ktarmarket/market/marketpage.dart';
import 'package:ktarmarket/report/reportpage.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        centerTitle: true,
      ),
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const MarketPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.store, size: 50), Text('Market')],
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ReportPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.report, size: 50), Text('Report')],
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const BookingPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.book, size: 50), Text('Booking')],
              ),
            ),
          ),
          const Card(
            child: Center(child: Text('Transportation')),
          ),
          const Card(
            child: Center(child: Text('Outing')),
          ),
        ],
      ),
    );
  }
}
