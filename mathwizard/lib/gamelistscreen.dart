// ignore_for_file: unused_import, must_be_immutable

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/gamea/gameamainscreen.dart';
import 'package:mathwizard/gameb/gamebmainscreen.dart';
import 'package:mathwizard/gamec/gamecmainscreen.dart';
import 'package:mathwizard/gamed/gamedmainscreen.dart';
import 'package:mathwizard/gamee/gameemainscreen.dart';
import 'package:mathwizard/gamef/gamefmainscreen.dart';
import 'package:mathwizard/models/audioservice.dart';
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
    final List<Map<String, String>> games = [
      {
        "title": "Quik Math",
        "desc": "Solve rapid-fire arithmetic before time runs out.",
      },
      {
        "title": "Sequence Hunter",
        "desc": "Find and fill missing numbers in number sequences.",
      },
      {
        "title": "Math Maze",
        "desc": "Navigate a maze by solving sum targets to proceed.",
      },
      {
        "title": "Equation Builder",
        "desc": "Build valid equations that hit the given target.",
      },
      {
        "title": "Math Runner",
        "desc": "Choose the correct math gates while running against time.",
      },
      {
        "title": "Number Pyramid",
        "desc": "Fill in pyramid blocks using addition logic.",
      },
      {
        "title": "Budget Hero",
        "desc": "Manage your budget and reach savings goals.",
      },
      {
        "title": "Prime Time",
        "desc": "Quickly identify prime numbers in a grid.",
      },
      {
        "title": "Fraction Frenzy",
        "desc": "Simplify and compare fractions under pressure.",
      },
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProfileScreen(user: widget.user),
                              ),
                            );
                            _reloadUser();
                          },
                          child: ClipOval(
                            child: Image.network(
                              "https://slumberjer.com/mathwizard/uploads/profile_images/profile_${widget.user.userId}.jpg",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/mathwizard.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              },
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
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            RewardScreen(user: widget.user),
                                  ),
                                );
                                _reloadUser();
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
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            RankScreenMenu(user: widget.user),
                                  ),
                                );
                                _reloadUser();
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
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            TradeScreen(user: widget.user),
                                  ),
                                );
                                _reloadUser();
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
                        final game = games[index];
                        final title = game['title']!;
                        final desc = game['desc']!;
                        return InkWell(
                          onTap: () => _handleGameTap(title),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          desc,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
                        final game = games[index];
                        final title = game['title']!;
                        final desc = game['desc']!;
                        return InkWell(
                          onTap: () => _handleGameTap(title),
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
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                desc,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      // Play game audio
      AudioService.playSfx('sounds/start.wav');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameAMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Sequence Hunter") {
      AudioService.playSfx('sounds/start.wav');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameBMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Math Maze") {
      AudioService.playSfx('sounds/start.wav');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameCMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Equation Builder") {
      AudioService.playSfx('sounds/start.wav');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameDMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Math Runner") {
      AudioService.playSfx('sounds/start.wav');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameEMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else if (gameName == "Number Pyramid") {
      AudioService.playSfx('sounds/start.wav');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameFMainScreen(user: widget.user)),
      );
      await _reloadUser();
    } else {
      AudioService.playSfx('sounds/wrong.wav');
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

  // _reloadUser() async {
  //   try {
  //     // Temp solution to bypass SSL certificate error
  //     HttpClient createHttpClient() {
  //       final HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //       return httpClient;
  //     }

  //     final ioClient = IOClient(createHttpClient());
  //     final url = Uri.parse(
  //       "https://slumberjer.com/mathwizard/api/reload_user.php",
  //     );
  //     final response = await ioClient.post(
  //       url,
  //       body: {'userid': widget.user.userId.toString()},
  //     );
  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);
  //       if (responseBody['status'] == 'success') {
  //         setState(() {
  //           widget.user = User.fromJson(responseBody['data']);
  //         });
  //         ("User info reloaded successfully.");
  //         // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         //   content: Text("User info reloaded successfully."),
  //         // ));
  //       } else {}
  //     } else {}
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  _reloadUser() async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/reload_user.php",
      ); // Changed to HTTP

      final response = await http.post(
        url,
        body: {'userid': widget.user.userId.toString()},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            widget.user = User.fromJson(responseBody['data']);
          });
          log("User info reloaded successfully.");
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("User info reloaded successfully."),
          // ));
        } else {
          log("Server responded with failure status.");
        }
      } else {
        log("Server error: ${response.statusCode}");
      }
    } catch (e) {
      log("Error occurred: $e");
    }
  }
}
