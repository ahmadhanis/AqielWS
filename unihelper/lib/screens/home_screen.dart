import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniHelper Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Welcome, ${userProvider.username}'),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Enter your name'),
            ),
            ElevatedButton(
              onPressed: () {
                userProvider.setUsername(controller.text);
              },
              child: const Text('Update Username'),
            ),
          ],
        ),
      ),
    );
  }
}
