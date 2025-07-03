// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktargo/model/item.dart';
import 'package:ktargo/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:ktargo/shared/animated_route.dart';
import 'package:ktargo/shared/myconfig.dart';
import 'package:ktargo/shared/mydrawer.dart';
import 'package:ktargo/view/edititemscreen.dart';
import 'package:ktargo/view/loginscreen.dart';
import 'package:ktargo/view/newitemscreen.dart';
import 'package:ktargo/view/registerscreen.dart';

class UserItemScreen extends StatefulWidget {
  final User user;
  const UserItemScreen({super.key, required this.user});

  @override
  State<UserItemScreen> createState() => _UserItemScreenState();
}

class _UserItemScreenState extends State<UserItemScreen> {
  List<Item> itemList = <Item>[]; // List of item objects
  late double screenWidth, screenHeight;
  int ran = Random().nextInt(1000); // Random number for image cache busting
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    loadUserItems();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.userName} Items'),
        flexibleSpace: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade900, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        color: Colors.amber.shade900,
        onRefresh: () async {
          loadUserItems();
        },
        child:
            itemList.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "No items found.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You haven't listed any items yet.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            AnimatedRoute.slideFromRight(
                              NewItemScreen(user: widget.user),
                            ),
                          );
                          loadUserItems();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Your First Item"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    int crossAxisCount;

                    if (width > 1200) {
                      crossAxisCount = 3; // Desktop
                    } else if (width > 800) {
                      crossAxisCount = 2; // Tablet
                    } else {
                      crossAxisCount = 1; // Mobile
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: itemList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio:
                            width > 1200 ? 3.8 : (width > 800 ? 3.5 : 2.8),
                      ),
                      itemBuilder: (context, index) {
                        final item = itemList[index];
                        final imageUrl =
                            "${MyConfig.myurl}uploads/assets/images/items/item-${item.itemId}.png?v=$ran";

                        return Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            onLongPress: () => updateStatusDialog(item),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      imageUrl,
                                      width: width > 1200 ? 130 : width * 0.2,
                                      height: screenHeight * 0.13,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 80,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          truncateString(
                                            item.itemName.toString(),
                                            15,
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.purple.shade600,
                                          ),
                                        ),
                                        Text("Price: RM ${item.itemPrice}"),
                                        Text("Qty: ${item.itemQty}"),
                                        Text("Delivery: ${item.itemDelivery}"),
                                        Text(
                                          "Date: ${formatDate(item.itemDate)}",
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action buttons
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: Colors.blue,
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => EditItemScreen(
                                                    user: widget.user,
                                                    item: item,
                                                  ),
                                            ),
                                          );
                                          loadUserItems();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.sell),
                                        color: Colors.amber.shade900,
                                        onPressed:
                                            () => updateStatusDialog(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () => deleteDialog(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.user.userId == "0") {
            askloginorRegisterDialog(context);
          } else {
            if (widget.user.userCredit == "0") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You need to top up your credit first."),
                ),
              );
              return;
            }
            await Navigator.push(
              context,
              AnimatedRoute.slideFromRight(NewItemScreen(user: widget.user)),
            );
            loadUserItems();
          }
        },
        // backgroundColor: Colors.purple.shade600,
        child: const Icon(Icons.add),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void askloginorRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Login or Register"),
            content: const Text("You need to login or register to add items."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text("Login"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text("Register"),
              ),
            ],
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

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat("dd/MM/yyyy").format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }

  void loadUserItems() {
    String userid = widget.user.userId.toString();
    http
        .get(Uri.parse("${MyConfig.myurl}api/load_items.php?userid=$userid"))
        .then((response) {
          // log(response.body);
          // print(response.body);
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);

            if (data['status'] == 'success') {
              itemList.clear();
              data['data'].forEach((myitem) {
                //  print(myitem);
                Item t = Item.fromJson(myitem);
                itemList.add(t);
              });
              setState(() {});
            }
          }
        });
  }

  void deleteDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: Text("Are you sure you want to delete ${item.itemName}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteItem(item);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void deleteItem(Item item) {
    String itemId = item.itemId.toString();
    http
        .post(
          body: {
            // "userid":"${widget.user.userId}",
            "itemid": itemId,
          },
          Uri.parse("${MyConfig.myurl}api/delete_item.php"),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${item.itemName} deleted successfully."),
                ),
              );
              loadUserItems(); // Refresh the item list
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to delete item.")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error deleting item.")),
            );
          }
        });
  }

  void updateStatusDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Status"),
          content: Text(
            "Are you sure you want to update the status of ${item.itemName} to 'Sold'?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateStatus(item);
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void updateStatus(Item item) {
    String itemId = item.itemId.toString();
    http
        .post(
          body: {
            // "userid":"${widget.user.userId}",
            "item_id": itemId,
            "item_status": "sold",
          },
          Uri.parse("${MyConfig.myurl}api/update_item_status.php"),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${item.itemName} status updated successfully.",
                  ),
                ),
              );
              loadUserItems(); // Refresh the item list
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to update item status.")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error updating item status.")),
            );
          }
        });
  }
}
