import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mathwizard/models/user.dart';

class RankScreenMenu extends StatefulWidget {
  final User user;
  const RankScreenMenu({super.key, required this.user});

  @override
  State<RankScreenMenu> createState() => _RankScreenMenuState();
}

class _RankScreenMenuState extends State<RankScreenMenu> {
  String? selectedSchool; // Selected school code
  late Future<List<Map<String, dynamic>>> rankings; // Rankings data
  List<Map<String, String>> sarawakSchools = [
    {"code": "SK000", "name": "All"},
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

  String selectedStandard = "1";

  @override
  void initState() {
    super.initState();
    // Default to the first school
    selectedSchool = sarawakSchools.first["code"];
    rankings = fetchRankings(selectedSchool!, selectedStandard);
  }

  // Future<List<Map<String, dynamic>>> fetchRankings(
  //   String schoolCode,
  //   String selectedStandard,
  // ) async {
  //   HttpClient _createHttpClient() {
  //     final HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //     return httpClient;
  //   }

  //   final ioClient = IOClient(_createHttpClient());

  //   try {
  //     final url = Uri.parse(
  //       "https://slumberjer.com/mathwizard/api/ranking.php?school_code=$schoolCode&standard=$selectedStandard",
  //     );
  //     final response = await ioClient
  //         .get(url)
  //         .timeout(const Duration(seconds: 5));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['status'] == 'success') {
  //         return List<Map<String, dynamic>>.from(data['data']);
  //       } else {
  //         throw Exception(data['message'] ?? 'Failed to load rankings');
  //       }
  //     } else {
  //       throw Exception('Failed to connect to server');
  //     }
  //   } catch (e) {
  //     throw Exception('No ranking available');
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchRankings(
    String schoolCode,
    String selectedStandard,
  ) async {
    try {
      final url = Uri.parse(
        "https://slumberjer.com/mathwizard/api/ranking.php?school_code=$schoolCode&standard=$selectedStandard", // Changed to HTTP
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load rankings');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      throw Exception('No ranking available');
    }
  }

  void refreshRankings() {
    setState(() {
      rankings = fetchRankings(selectedSchool!, selectedStandard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("School Rankings"), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // Dropdown for School Selection
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: DropdownButtonFormField<String>(
                value: selectedSchool,
                items:
                    sarawakSchools
                        .map(
                          (school) => DropdownMenuItem(
                            value: school["code"],
                            child: Text(school["name"]!),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSchool = value!;
                  });
                  refreshRankings();
                },
                decoration: const InputDecoration(
                  labelText: "Select School",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Standard Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: DropdownButtonFormField<String>(
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
                    // ignore: avoid_print
                    print(value);
                  });
                  refreshRankings();
                },
                decoration: const InputDecoration(
                  labelText: "Select Standard",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Rankings List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: rankings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Oops! Something went wrong.",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(
                                () {},
                              ); // Trigger UI rebuild to retry fetching data
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No Rankings Available",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "There are no rankings available for the selected school.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(
                                () {},
                              ); // Trigger UI rebuild to retry fetching data
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Refresh"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final rankList = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: rankList.length,
                      itemBuilder: (context, index) {
                        final rank = rankList[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              child: Text("${index + 1}"),
                            ),
                            title: Text(rank['full_name']),
                            subtitle: Text("Coins: ${rank['coin']}"),
                            trailing: Text("Standard ${rank['standard']}"),
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
}
