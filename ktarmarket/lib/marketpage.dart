import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktarmarket/newitempage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

import 'item.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  //array of items object
  List<Item> itemList = <Item>[]; //list array objects
  String status = "Loading...";
  late double screenHeight, screenWidth;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  TextEditingController searchController = TextEditingController();
  String searchString = "";

  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItems();
  }

  void loadItems() {
    // TODO: implement loadItems
    http
        .get(Uri.parse(
            'http://ktarmarket.slumberjer.com/api/loaditems.php?search=$searchString&pageno=$curpage'))
        .then((response) {
      if (response.statusCode == 200) {
        //log(response.body);
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          itemList.clear();
          data['data']['items'].forEach((item) {
            // print(data['data']['items']);
            itemList.add(Item(
                itemId: item['item_id'],
                email: item['email'],
                phone: item['phone'],
                itemName: item['item_name'],
                itemStatus: item['item_status'],
                itemDescription: item['item_description'],
                itemDate: item['item_date'],
                price: item['price']));
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
        title: const Text(
          'KTAR Market',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple, Colors.purpleAccent],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: onsearchDialog,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              searchString = "";
              loadItems();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: itemList.isEmpty
          ? const Center(
              child: Text("No items available", style: TextStyle(fontSize: 18)))
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
                          itemCount: itemList.length,
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
                          itemCount: itemList.length,
                          itemBuilder: (context, index) {
                            return buildItemCard(index);
                          },
                        );
                      } else {
                        // 📱 Mobile → ListView (1 Item Per Row)
                        return ListView.builder(
                          itemCount: itemList.length,
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
                            loadItems();
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
                            loadItems();
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      // ➕ Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration:
                  const Duration(milliseconds: 300), // Animation Speed
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const NewItemPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Slide in from right
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );

          loadItems();
        },
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  // 🏷️ Item Card (Reusable for List & Grid)
  Widget buildItemCard(int index) {
    String url =
        "https://ktarmarket.slumberjer.com/images/${itemList[index].itemId}.png";
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
            onTap: () => itemDetailsDialog(index),
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
                              itemList[index].itemName.toString(), 20),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign:
                              TextAlign.center, // Centers text horizontally
                        ),
                        Text(
                          "RM ${double.parse(itemList[index].price.toString()).toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          itemList[index].itemStatus.toString(),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          df.format(DateTime.parse(
                              itemList[index].itemDate.toString())),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // 📲 WhatsApp Icon
                  IconButton(
                    onPressed: () => launchUrlString(
                        'https://wa.me/${itemList[index].phone.toString()}'),
                    icon: const Icon(Icons.wechat, color: Colors.green),
                  ),
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

  void itemDetailsDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double dialogWidth = constraints.maxWidth < 600
                  ? MediaQuery.of(context).size.width *
                      0.9 // Mobile (90% width)
                  : MediaQuery.of(context).size.width *
                      0.5; // Tablet/Desktop (50% width)

              return Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📌 Item Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          "https://ktarmarket.slumberjer.com/images/${itemList[index].itemId}.png",
                          height: MediaQuery.of(context).size.height / 3,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  size: 100, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 📌 Item Name
                      Text(
                        itemList[index].itemName.toString(),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // 📌 Description
                      Text(
                        itemList[index].itemDescription.toString(),
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),

                      // 💰 Price
                      Text(
                        "RM ${double.parse(itemList[index].price.toString()).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 16),

                      // 📅 Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.purple),
                          const SizedBox(width: 10),
                          Text(df.format(DateTime.parse(
                              itemList[index].itemDate.toString()))),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 📧 Email
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(itemList[index].email.toString(),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 📞 Phone
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.teal),
                          const SizedBox(width: 10),
                          Text(itemList[index].phone.toString()),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 🏷 Status
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.orange),
                          const SizedBox(width: 10),
                          Text(itemList[index].itemStatus.toString()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔘 Contact Buttons (Call, WhatsApp, Email)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 📞 Call Button
                          IconButton(
                            onPressed: () => launchUrlString(
                                'tel://${itemList[index].phone.toString()}'),
                            icon: const Icon(Icons.phone,
                                size: 40, color: Colors.teal),
                          ),

                          // 🟢 WhatsApp Button
                          IconButton(
                            onPressed: () => launchUrlString(
                                'https://wa.me/${itemList[index].phone.toString()}'),
                            icon: const Icon(Icons.wechat,
                                size: 40, color: Colors.green),
                          ),

                          // 📧 Email Button
                          IconButton(
                            onPressed: () => launchUrlString(
                                'mailto://${itemList[index].email.toString()}'),
                            icon: const Icon(Icons.email,
                                size: 40, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ❌ Close Button
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                          ),
                          child: const Text('Close',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void onsearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = constraints.maxWidth > 1200
                ? MediaQuery.of(context).size.width *
                    0.4 // Desktop: 40% of screen width
                : constraints.maxWidth > 600
                    ? MediaQuery.of(context).size.width *
                        0.6 // Tablet: 60% of screen width
                    : MediaQuery.of(context).size.width *
                        0.9; // Mobile: 90% of screen width

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📌 Title
                    const Text(
                      'Search',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // 🔍 Search Input Field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Enter keyword...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔘 Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 🔎 Search Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            searchString = searchController.text;
                            loadItems();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text('Search',
                              style: TextStyle(color: Colors.white)),
                        ),

                        // ❌ Close Button
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text('Close',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
