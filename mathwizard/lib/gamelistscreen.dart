// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/io_client.dart';

import 'package:http/http.dart' as http;
import 'package:mathwizard/gamea/gameamainscreen.dart';
import 'package:mathwizard/gameb/gamebmainscreen.dart';
import 'package:mathwizard/gamec/gamecmainscreen.dart';
import 'package:mathwizard/models/user.dart';
import 'package:mathwizard/profilescreen.dart';
import 'package:mathwizard/rankscreen.dart';
import 'package:mathwizard/rewards/rewardscreen.dart';
import 'package:mathwizard/tradescreen.dart';

class GameListScreen extends StatefulWidget {
  User user;

  GameListScreen({super.key, required this.user});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  @override
  Widget build(BuildContext context) {
    // List of games
    final List<String> games = [
      "Quik Math",
      "Sequence Hunter",
      "Math Maze",
      "Equation Builder",
      "Math Runner",
      "Number Pyramid",
      "Budget Hero",
      "Prime Time",
      "Fraction Frenzy",
    ];

    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Game List"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.lightBlue[50],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        // Avatar Section
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProfileScreen(user: widget.user),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              widget.user.fullName
                                  .toString()
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Welcome Text
                        Text(
                          "Hi Math Wizard, ${widget.user.fullName}!",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // User Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.user.email.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.grade, color: Colors.amber),
                                const SizedBox(height: 4),
                                Text(
                                  "Standard ${widget.user.standard}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Coins, Tries, Rewards, Rank, Trade
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Coins
                            GestureDetector(
                              onTap: _reloadUser,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Colors.orange,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${widget.user.coin}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Text(
                                    "Coins",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // Tries
                            Column(
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.green,
                                  size: 30,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${widget.user.dailyTries}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  "Tries",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),

                            // Rewards
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            RewardScreen(user: widget.user),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.card_giftcard,
                                    color: Colors.pink,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Rewards",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // Rank
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            RankScreenMenu(user: widget.user),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.leaderboard,
                                    color: Colors.blueAccent,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Rank",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // Trade
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            TradeScreen(user: widget.user),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.swap_horiz,
                                    color: Colors.cyan,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Trade",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Game List Section
                const Text(
                  "Available Games:",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),

                // Responsive Grid/List of Games
                isWideScreen
                    ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3.2,
                          ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _handleGameTap(games[index]),
                          borderRadius: BorderRadius.circular(15),
                          child: Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.deepPurpleAccent,
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      games[index],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _handleGameTap(games[index]),
                          borderRadius: BorderRadius.circular(15),
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                games[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.play_arrow,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGameTap(String gameName) async {
    if (gameName == "Quik Math") {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameAMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Sequence Hunter") {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameBMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Math Maze") {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameCMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Coming Soon!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              content: const Text(
                "The game you selected is not available yet.\nStay tuned for future updates!",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
      );
    }
  }

  _reloadUser() async {
    try {
      // Temp solution to bypass SSL certificate error
      HttpClient createHttpClient() {
        final HttpClient httpClient = HttpClient();
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return httpClient;
      }

      final ioClient = IOClient(createHttpClient());
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/reload_user.php",
      );
      final response = await ioClient.post(
        url,
        body: {'userid': widget.user.userId.toString()},
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user = User.fromJson(responseBody['data']);
          });
          ("User info reloaded successfully.");
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("User info reloaded successfully."),
          // ));
        } else {}
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }
}
