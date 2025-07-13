// ignore_for_file: unnecessary_const, use_build_context_synchronously, library_private_types_in_public_api, empty_catches

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'gamelistscreen.dart';
import 'registerscreen.dart';
import 'models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  // Future<void> login() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   // Temp solution to bypass SSL certificate error
  //   HttpClient _createHttpClient() {
  //     final HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //     return httpClient;
  //   }

  //   final ioClient = IOClient(_createHttpClient());

  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     final url = Uri.parse("https://slumberjer.com/mathwizard/api/login.php");
  //     final response = await ioClient
  //         .post(
  //           url,
  //           body: {
  //             'email': emailController.text.trim(),
  //             'password': passwordController.text.trim(),
  //           },
  //         )
  //         .timeout(const Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);
  //       if (responseBody['status'] == 'success') {
  //         // Save credentials if Remember Me is checked
  //         await _saveCredentials();
  //         print(responseBody.data);
  //         // Parse user object
  //         User user = User.fromJson(responseBody['data']);
  //         // print(user.fullName);
  //         // Navigate to GameListScreen and pass the User object
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (_) => GameListScreen(user: user)),
  //         );
  //       } else {
  //         // Show error message
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text(responseBody['message'])));
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Failed to connect to server.")),
  //       );
  //     }
  //   } on TimeoutException catch (_) {
  //     // Handle timeout
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Request timed out. Please try again.")),
  //     );
  //   } catch (e) {
  //     // Handle other exceptions
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));

  //     print("$e");
  //   }
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("https://slumberjer.com/mathwizard/api/login.php");
      final response = await http
          .post(
            url,
            body: {
              'email': emailController.text.trim(),
              'password': passwordController.text.trim(),
            },
          )
          .timeout(const Duration(seconds: 10));

      // Debug
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          await _saveCredentials();
          // ✅ FIXED
          print('Before USER');
          User user = User.fromJson(responseBody['data']); // ✅ FIXED
          print('Before USER');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameListScreen(user: user)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Unknown error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to connect to server.")),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request timed out. Please try again.")),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    }

    setState(() {
      isLoading = false;
    });
  }

  void navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void navigateToForgotPassword() {
    TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Forgot Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter your email"),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Send email to reset password
                  Navigator.pop(context);
                  resetPassword(emailController.text.trim());
                },
                child: const Text("Submit"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: mediaQuery.size.width > 600 ? 400 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Icon or Friendly Wizard Image
                      Image.asset('assets/images/mathwizard.png', width: 120),
                      const SizedBox(height: 20),

                      const Text(
                        "Let’s Start Learning!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Login to begin your Math Adventure!",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email.";
                          } else if (!RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ).hasMatch(value)) {
                            return "Please enter a valid email.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Remember Me and Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),
                              const Text("Remember Me"),
                            ],
                          ),
                          TextButton(
                            onPressed: navigateToForgotPassword,
                            child: const Text(
                              "Forgot?",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 20),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No account?"),
                          TextButton(
                            onPressed: navigateToRegister,
                            child: const Text(
                              "Register here",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> resetPassword(String emailreset) async {
  //   HttpClient createHttpClient() {
  //     final HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //     return httpClient;
  //   }

  //   final ioClient = IOClient(createHttpClient());

  //   try {
  //     final url = Uri.parse("https://slumberjer.com/mathwizard/api/reset.php");
  //     final response = await ioClient
  //         .post(url, body: {'email': emailreset})
  //         .timeout(const Duration(seconds: 5));
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);
  //       print(response.body);
  //       if (responseBody['status'] == 'success') {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: const Text("Success. Please check your email"),
  //             duration: Duration(seconds: 3),
  //           ),
  //         );
  //       } else {
  //         // Show error message
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(const SnackBar(content: Text("Error")));
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Failed to connect to server.")),
  //       );
  //     }
  //   } on TimeoutException catch (_) {
  //     // Handle timeout
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Request timed out. Please try again.")),
  //     );
  //   } catch (e) {
  //     // Handle other exceptions
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   SnackBar(
  //     //     content: Text("An error occurred: $e"),
  //     //   ),
  //     // );

  //     print("$e");
  //   }
  // }

  Future<void> resetPassword(String emailreset) async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/reset.php",
      ); // Changed to HTTP
      final response = await http
          .post(url, body: {'email': emailreset})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Success. Please check your email"),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Error")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to connect to server.")),
        );
      }
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request timed out. Please try again.")),
      );
    } catch (e) {}
  }
}
