// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mybudget/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBudget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme, // Merge with existing theme styles
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red, // Set app bar background color
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // App bar title color
          ),
          iconTheme:
              const IconThemeData(color: Colors.white), // Icon color in AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded button corners
            ),
            backgroundColor: Colors.red, // Button background color
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/mybudget.png',
            height: 200,
            width: 200,
          ),
          const Text(
            "MyBudget",
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          const CircularProgressIndicator()
        ],
      )),
    );
  }
}
