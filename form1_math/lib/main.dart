import 'package:flutter/material.dart';
import 'package:form1_math/topicssreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for the fade transition.
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // A curved fade-in animation.
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    // Start the animation.
    _animationController.forward();

    // Navigate to the next screen after a 3-second delay.
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TopicsScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Container with a gradient background.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // FadeTransition makes the child fade in.
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replace this Icon with your logo image if desired.
                Icon(
                  Icons.calculate,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Math App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // A progress indicator to signal loading.
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
