// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mathwizard/models/reward.dart';
import 'package:mathwizard/models/user.dart';
import 'package:http/http.dart' as http;

class RewardScreen extends StatefulWidget {
  final User user;

  const RewardScreen({super.key, required this.user});

  @override
  _RewardScreenState createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late Future<List<Reward>> _rewards;

  @override
  void initState() {
    super.initState();
    _rewards = fetchRewards();
  }

  Future<List<Reward>> fetchRewards() async {
    final url = Uri.parse(
      "https://slumberjer.com/mathwizard/api/get_rewards.php", // Changed to HTTP
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> rewardData = json.decode(response.body)['data'];
      return rewardData.map((json) => Reward.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load rewards");
    }
  }

  // Future<List<Reward>> fetchRewards() async {
  //   // Temp solution to bypass SSL certificate error
  //   HttpClient createHttpClient() {
  //     final HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //     return httpClient;
  //   }

  //   final ioClient = IOClient(createHttpClient());
  //   final url = Uri.parse(
  //     "https://slumberjer.com/mathwizard/api/get_rewards.php",
  //   );
  //   final response = await ioClient.get(url);

  //   if (response.statusCode == 200) {
  //     final List<dynamic> rewardData = json.decode(response.body)['data'];
  //     return rewardData.map((json) => Reward.fromJson(json)).toList();
  //   } else {
  //     throw Exception("Failed to load rewards");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLargeScreen = mediaQuery.size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Rewards"), centerTitle: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        child: Text(
                          widget.user.fullName.toString().substring(0, 2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, ${widget.user.fullName}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Coins: ${widget.user.coin}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                "Under Development!!!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Rewards Section
            Expanded(
              child: FutureBuilder<List<Reward>>(
                future: _rewards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No rewards available"));
                  } else {
                    final rewards = snapshot.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLargeScreen ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isLargeScreen ? 1.5 : 0.8,
                      ),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        final isRedeemable =
                            int.parse(reward.stockQuantity) > 0 &&
                            int.parse(widget.user.coin.toString()) >=
                                int.parse(reward.coinCost);

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              showRewardDetails(reward);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reward.rewardName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    truncateString(reward.description, 25),
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${reward.coinCost} Coins",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        "Qty: ${reward.stockQuantity}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed:
                                        isRedeemable
                                            ? () {
                                              // Redeem Reward Logic Here
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Reward system still under development!",
                                                  ),
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isRedeemable
                                              ? Colors.blue
                                              : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Redeem"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  void showRewardDetails(Reward reward) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              reward.rewardName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display reward image
                  Center(
                    child: Image.network(
                      "https://slumberjer.com/mathwizard/images/${reward.rewardId}",
                      fit: BoxFit.cover,
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.7, // or 0.8
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Display reward details
                  const Text(
                    "Description:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    reward.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${reward.category}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Provider: ${reward.provider}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Cost: ${reward.coinCost} Coins",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Stock: ${reward.stockQuantity}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }
}
