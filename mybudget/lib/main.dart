// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mybudget/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize the SDK
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyBudget',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
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
    super.initState();
    checkAppVersion(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 20,
          ),
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
          const CircularProgressIndicator(),
          Text("Develop by Muhammad Aqiel Akhtar\nIPGKTAR",
              textAlign: TextAlign.center, style: GoogleFonts.poppins()),
          Text("Version 1.0.0", style: GoogleFonts.poppins()),
        ],
      )),
    );
  }

  static Future<void> checkAppVersion(BuildContext context) async {
    try {
      final response = await http
          .get(Uri.parse('https://slumberjer.com/mybudget/check_version.php'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final localVersion =
            (await rootBundle.loadString('assets/version.txt')).trim();

        if (data['status'] == 'maintenance') {
          _showExitDialog(
            context,
            "Maintenance Mode",
            data['maintenance_notice'] ??
                "The app is currently under maintenance. Please try again later.",
          );
          return;
        }

        if (localVersion != data['current_version']) {
          _showExitDialog(
            context,
            "Update Required",
            "A new version (${data['current_version']}) is available. \n${data['message'] ?? ''}",
          );
          return;
        }

        // Proceed to login if version matches
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        });
      } else {
        _showExitDialog(context, "Server Error", "Could not check version.");
      }
    } on TimeoutException {
      _showExitDialog(
        context,
        "Server Timeout",
        "The server did not respond in time. It may be under maintenance. Please try again later.",
      );
    } catch (e) {
      _showExitDialog(
        context,
        "Unexpected Error",
        "An error occurred while checking app status.",
      );
    }
  }

  static void _showExitDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Exit App"),
            onPressed: () async {
              if (kIsWeb) {
                // 🌐 Web: Open external site
                const url = 'https://www.ipgmktar.edu.my/';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              } else if (Platform.isAndroid) {
                SystemNavigator.pop(); // 🤖 Android: Gracefully close app
              } else if (Platform.isIOS) {
                exit(0); // 🍎 iOS: Force exit
              }
            },
          ),
        ],
      ),
    );
  }

  static void _showInfoDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
