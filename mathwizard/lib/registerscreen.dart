// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mathwizard/models/schools.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false; // To toggle password visibility
  String selectedStandard = '1';
  String selectedSchool = '';
  Schools schools = Schools();

  @override
  void initState() {
    super.initState();
    selectedSchool = schools.penangSchools.first["code"]!;
  }

  void autoGeneratePassword() {
    final random = Random();
    const chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final password =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {
      passwordController.text = password;
    });
  }

  Future<void> registerUser() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final url = Uri.parse("https://slumberjer.com/mathwizard/api/register.php");
    final response = await http.post(
      url,
      body: {
        'full_name': fullName, // User's full name
        'email': email, // User's email
        'password': password, // User's password
        'standard': selectedStandard, // User's standard (e.g., 1, 2, etc.)
        'school_code': selectedSchool, // School code
        'coin': '0', // Default coin value (optional)
        'daily_tries': '5', // Default daily tries (optional)
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Registration Successful"),
              content: Text(
                responseBody['message'] ?? "Please check your email!",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pop(); // Navigate back to the previous screen
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Registration Failed"),
              content: Text(
                "Error: ${response.reasonPhrase ?? 'Unknown error occurred'}",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  Future<void> confirmRegistration() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirm Registration"),
            content: const Text("Do you want to submit your registration?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Confirm"),
              ),
            ],
          ),
    );

    if (isConfirmed ?? false) {
      await registerUser();
    }
  }

  void handleRegister() {
    if (_formKey.currentState!.validate()) {
      confirmRegistration();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Register"), centerTitle: true),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 600 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Create a New Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    TextFormField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your full name.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
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

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a password.";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for Standard
                    DropdownButtonFormField<String>(
                      value: selectedStandard,
                      items: List.generate(
                        6,
                        (index) => DropdownMenuItem(
                          value: (index + 1).toString(),
                          child: Text("Standard ${index + 1}"),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedStandard = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Standard",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for Schools
                    DropdownButtonFormField<String>(
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontFamily: 'ComicSans',
                      ),
                      value: selectedSchool,
                      items:
                          schools.penangSchools
                              .map(
                                (school) => DropdownMenuItem(
                                  value: school["code"],
                                  child: Text(
                                    "${school["name"]} (${school["code"]})",
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSchool = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Select School",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Register Button
                    ElevatedButton(
                      onPressed: handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 18),
                      ),
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
}
