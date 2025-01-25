import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Register Screen'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: rePasswordController,
              decoration: const InputDecoration(
                labelText: 'Re-enter Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                registerUserDialog();
              },
              child: const Text('Register'),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: const Text("Already have an account? Login here"),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  void registerUserDialog() {
    String email = emailController.text;
    String password = passwordController.text;
    String repassword = rePasswordController.text;

    if (email.isEmpty || password.isEmpty || repassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email/password cannot be empty'),
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email'),
        ),
      );
      return;
    }

    if (password != repassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password does not match'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Register new account'),
              content: const Text('Are you sure?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    registerUser(email, password);
                  },
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  void registerUser(String email, String password) {
    http.post(Uri.parse("http://slumberjer.com/caritukang/register.php"),
        body: {"email": email, "password": password}).then((response) {
      if (response.statusCode == 200) {
        print(response.body);
      }
    });
  }
}
