// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mybudget/daily_report_screen.dart';
import 'package:mybudget/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false; // Remember Me checkbox state
  double? screenWidth, screenHeigth;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword(); // Load saved email and password if available
    _checkAgreement();
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-8395142902989782/3300133484', // Replace with your AdMob Banner ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  // Load email and password from SharedPreferences
  void _loadUserEmailPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    bool? rememberMe = prefs.getBool('remember_me');

    if (rememberMe != null && rememberMe) {
      setState(() {
        _emailController.text = savedEmail ?? '';
        _passwordController.text = savedPassword ?? '';
        _rememberMe = rememberMe;
      });
    }
  }

  // Save email and password to SharedPreferences
  void _saveUserEmailPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('remember_me', _rememberMe);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences Saved'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('remember_me', false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences Removed')),
      );
      _emailController.text = '';
      _passwordController.text = '';
      _rememberMe = false;
      setState(() {});
    }
  }

  // Example login function
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Backend URL
      String url = 'https://slumberjer.com/mybudget/login.php';

      // Get the email and password from the form fields
      String email = _emailController.text;
      String password = _passwordController.text;

      // Check if email and password fields are not empty
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both email and password')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        // Send POST request to backend
        final response = await http.post(
          Uri.parse(url),
          body: {
            'email': email,
            'password': password,
          },
        );

        // Check if the response is successful
        if (response.statusCode == 200) {
          // Decode the JSON response
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            // Login successful, retrieve the user ID
            int userId = jsonResponse['user_id'];

            // Show login successful message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Successful'),
                duration: Duration(seconds: 1),
              ),
            );

            // Navigate to MyBudgetPage and pass the user ID
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyBudgetPage(
                  title: "MyBudget",
                  userId: userId, // Pass the userId to MyBudgetPage
                ),
              ),
            );
          } else {
            // Login failed, show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(jsonResponse['message'] ?? 'Login Failed')),
            );
          }
        } else {
          // Error occurred
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        // Handle any exceptions during the request
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        // Hide loading indicator
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; //get screen width
    screenHeigth = MediaQuery.of(context).size.height / 1.5;
    if (screenWidth! > 600) {
      screenWidth = 600;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SizedBox(
              width: screenWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Remember Me Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                    _saveUserEmailPassword();
                                  });
                                },
                              ),
                              const Text(
                                'Remember Me',
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Login Button
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen()));
                          _loadUserEmailPassword(); // Load saved email and password if available
                        },
                        child: const Text(
                          'New Account? Sign Up?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _showForgotPasswordDialog(context);
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isBannerAdReady)
                      Container(
                        
                        height: _bannerAd.size.height.toDouble(),
                        width: screenWidth,
                        child: AdWidget(ad: _bannerAd),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    TextEditingController forgotPasswordEmailController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Please enter your email address to reset your password:'),
              const SizedBox(height: 10),
              TextField(
                controller: forgotPasswordEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = forgotPasswordEmailController.text;

                if (email.isNotEmpty) {
                  // Prepare the URL to send the forgot password request
                  String url =
                      'https://slumberjer.com/mybudget/forgot_password.php';

                  try {
                    // Send the HTTP POST request to the backend
                    final response = await http.post(
                      Uri.parse(url),
                      body: {
                        'email': email, // Send the email in the POST body
                      },
                    );

                    if (response.statusCode == 200) {
                      // Decode the JSON response
                      // print(response.body);
                      var jsonResponse = json.decode(response.body);

                      if (jsonResponse['success']) {
                        // Show success message if the backend returns success
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Password reset link sent to $email')),
                        );
                      } else {
                        // Show error message if the backend returns an error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error: ${jsonResponse['message']}')),
                        );
                      }

                      // Close the dialog after sending the request
                      Navigator.of(context).pop();
                    } else {
                      // Handle error response from the server
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Server error. Please try again later.')),
                      );
                    }
                  } catch (e) {
                    // Handle any exceptions, such as network errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error occurred: $e')),
                    );
                  }
                } else {
                  // If the email field is empty, show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter an email address')),
                  );
                }
              },
              child: const Text(
                'Send Reset Link',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> _checkAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    final agreed = prefs.getBool('agreedToTerms') ?? false;

    if (!agreed) {
      await Future.delayed(Duration.zero);
      _showTermsDialog();
    }
  }

  void _showTermsDialog() {
    bool isChecked = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final maxWidth = MediaQuery.of(context).size.width;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.privacy_tip,
                        size: 60, color: Colors.deepPurple),
                    const SizedBox(height: 12),
                    const Text(
                      "Terms of Use",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Please read and accept the terms to continue using MyBudget.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: maxWidth < 600 ? 300 : 400),
                        child: const Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TermItem(
                                    "1. This app is under active development and may contain bugs."),
                                TermItem(
                                    "2. Your data is stored in an online database."),
                                TermItem(
                                    "3. You may be required to update the app periodically."),
                                TermItem(
                                    "4. Ads may be shown occasionally to support development."),
                                TermItem(
                                    "5. Anonymous usage data may be collected to improve performance."),
                                TermItem(
                                    "6. You're responsible for any data that you entered."),
                                TermItem(
                                    "7. The app is provided 'as is' with no warranties."),
                                TermItem(
                                    "8. Continued use of the app constitutes acceptance of these terms."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (val) =>
                              setState(() => isChecked = val ?? false),
                        ),
                        const Expanded(
                            child: Text("I agree to the terms of use")),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isChecked
                          ? () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('agreedToTerms', true);
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text("Accept and Continue",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class TermItem extends StatelessWidget {
  final String text;
  const TermItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
