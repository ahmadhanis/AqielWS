import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
  List<Map<String, String>> sarawakSchools = [
    {"code": "SK001", "name": "SK St Mary, Kuching"},
    {"code": "SK002", "name": "SK St Thomas, Kuching"},
    {"code": "SK003", "name": "SK St Joseph, Miri"},
    {"code": "SK004", "name": "SK Methodist, Sibu"},
    {"code": "SK005", "name": "SK Chung Hua, Bintulu"},
    {"code": "SK006", "name": "SK Merbau, Miri"},
    {"code": "SK007", "name": "SK Sg Plan, Bintulu"},
    {"code": "SK008", "name": "SK Nanga Oya, Kapit"},
    {"code": "SK009", "name": "SK Sibu Jaya, Sibu"},
    {"code": "SK010", "name": "SK Petra Jaya, Kuching"},
    {"code": "SK011", "name": "SK Siol Kanan, Kuching"},
    {"code": "SK012", "name": "SK Pujut Corner, Miri"},
    {"code": "SK013", "name": "SK Ulu Sebuyau, Samarahan"},
    {"code": "SK014", "name": "SK Matang Jaya, Kuching"},
    {"code": "SK015", "name": "SK Tanjung Batu, Bintulu"},
    {"code": "SK016", "name": "SK Lutong, Miri"},
    {"code": "SK017", "name": "SK Kidurong, Bintulu"},
    {"code": "SK018", "name": "SK Pujut, Miri"},
    {"code": "SK019", "name": "SK Sebauh, Bintulu"},
    {"code": "SK020", "name": "SK Agama Sibu, Sibu"},
    {"code": "SK021", "name": "SK Batu Lintang, Kuching"},
    {"code": "SK022", "name": "SK Jalan Arang, Kuching"},
    {"code": "SK023", "name": "SK Kampung Baru, Samarahan"},
    {"code": "SK024", "name": "SK Tabuan Jaya, Kuching"},
    {"code": "SK025", "name": "SK Lundu, Lundu"},
    {"code": "SK026", "name": "SK Bau, Bau"},
    {"code": "SK027", "name": "SK Serian, Serian"},
    {"code": "SK028", "name": "SK Padawan, Kuching"},
    {"code": "SK029", "name": "SK Asajaya, Samarahan"},
    {"code": "SK030", "name": "SK Sri Aman, Sri Aman"},
  ];

  @override
  void initState() {
    super.initState();
    selectedSchool = sarawakSchools.first["code"]!;
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
        builder: (_) => AlertDialog(
          title: const Text("Registration Successful"),
          content: Text(responseBody['message'] ?? "Please check your email!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(); // Navigate back to the previous screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Failed"),
          content: Text(
              "Error: ${response.reasonPhrase ?? 'Unknown error occurred'}"),
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
      builder: (_) => AlertDialog(
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
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),
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
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
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
                      value: selectedSchool,
                      items: sarawakSchools
                          .map((school) => DropdownMenuItem(
                                value: school["code"],
                                child: Text(
                                    "${school["name"]} (${school["code"]})"),
                              ))
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
