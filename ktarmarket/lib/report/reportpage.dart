import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktarmarket/report/newreportpage.dart';
import 'package:http/http.dart' as http;
import 'package:ktarmarket/report/report.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late double screenHeight, screenWidth;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  String searchString = "";
  String status = "Loading...";
  List<Report> reportList = <Report>[]; //list array objects

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadReport();
  }

  void loadReport() {
    http
        .get(Uri.parse(
            'https://ktarmarket.slumberjer.com/api/loadreports.php?search=$searchString&pageno=$curpage'))
        .then((response) {
      if (response.statusCode == 200) {
        log(response.body);
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          reportList.clear();
          data['data']['reports'].forEach((item) {
            reportList.add(Report(
                reportId: item['report_id'],
                email: item['email'],
                phone: item['phone'],
                reportType: item['report_type'],
                reportTitle: item['report_title'],
                reportDescription: item['report_description'],
                reportBuilding: item['report_building'],
                reportStatus: item['report_status'],
                reportDate: item['report_date']));
          });

          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
          print(numofpage);
          print(numofresult);
          setState(() {
            status = "Loaded";
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTAR Reports'),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red, Colors.redAccent],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              searchString = "";
              loadReport();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: reportList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🚫 No Items Icon
                    const Icon(Icons.search_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),

                    // 📢 Status Message
                    Text(
                      status.isNotEmpty ? status : "No items available.",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 🔄 Retry Button
                    ElevatedButton.icon(
                      onPressed: () => loadReport(), // Reload Function
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // 📊 Total Items & Pagination Info
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Total Items: $numofresult | Page: $curpage/$numofpage",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // 🔀 Responsive Grid/List Layout
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1200) {
                        // 🖥 Desktop → 3 Items Per Row
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 items per row on desktop
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio:
                                1.8, // Adjust aspect ratio for better fit
                          ),
                          itemCount: reportList.length,
                          itemBuilder: (context, index) {
                            return buildItemCard(index);
                          },
                        );
                      } else if (constraints.maxWidth > 600) {
                        // 📱 Tablet → 2 Items Per Row
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 items per row on tablet
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: reportList.length,
                          itemBuilder: (context, index) {
                            return buildItemCard(index);
                          },
                        );
                      } else {
                        // 📱 Mobile → ListView (1 Item Per Row)
                        return ListView.builder(
                          itemCount: reportList.length,
                          itemBuilder: (context, index) {
                            return buildItemCard(index);
                          },
                        );
                      }
                    },
                  ),
                ),
                // 🔼 Pagination Controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (curpage > 1) {
                            setState(() => curpage--);
                            loadReport();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      Text(
                        "Page $curpage",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          if (curpage < numofpage) {
                            setState(() => curpage++);
                            loadReport();
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewReportPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildItemCard(int index) {
    String url =
        "https://ktarmarket.slumberjer.com/images/report/${reportList[index].reportId}.png";
    print(url);

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth;
        double imageSize = cardWidth / 3; // Image width = 1/3 of card width

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🖼 Responsive Item Image (1/3 of card width)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: imageSize,
                      height: imageSize, // Maintain square ratio
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: imageSize,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 📋 Centered Item Details (Takes Remaining 2/3 Space)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Centers text horizontally
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Centers text vertically
                      children: [
                        Text(
                          truncateString(
                              reportList[index].reportTitle.toString(), 20),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign:
                              TextAlign.center, // Centers text horizontally
                        ),
                        Text(
                          (reportList[index].reportBuilding.toString()),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          reportList[index].reportType.toString(),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          df.format(DateTime.parse(
                              reportList[index].reportDate.toString())),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                            "Report Status: ${reportList[index].reportStatus}"),
                      ],
                    ),
                  ),

                  // 📲 WhatsApp Icon
                  // IconButton(
                  //   onPressed: () => launchUrlString(
                  //       'https://wa.me/${reportList[index].phone.toString()}'),
                  //   icon: const Icon(Icons.wechat, color: Colors.green),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String truncateString(String itemTitle, int length) {
    if (itemTitle.length > length) {
      itemTitle = "${itemTitle.substring(0, length)}...";
    }
    return itemTitle;
  }
}
