// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ktargo/model/user.dart';
import 'package:ktargo/shared/animated_route.dart';
import 'package:ktargo/shared/myconfig.dart';
import 'package:ktargo/shared/mydrawer.dart';
import 'package:ktargo/view/buycreditscreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name, phone, address, university, credit;
  File? _image;
  Uint8List? webImageBytes;
  late double screenHeight, screenWidth;

  final List<String> unilist = [
    "Akasia",
    "Bakawali",
    "Cempaka",
    "Dahlia",
    "Emas",
    "Freesia",
    "Gardenia",
  ];

  @override
  void initState() {
    super.initState();
    name = widget.user.userName ?? '-';
    phone = widget.user.userPhone ?? '-';
    address = widget.user.userAddress ?? '-';
    university = widget.user.userUniversity ?? '';
    credit = widget.user.userCredit ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade900, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: MyDrawer(user: user),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth < 600 ? double.infinity : 600,
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: _changeProfileImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _image != null
                                    ? _buildItemImage()
                                    : NetworkImage(
                                          "${MyConfig.myurl}ktargo/assets/images/profiles/${user.userId}.png",
                                        )
                                        as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _editableTile(Icons.school, "Block", university, () {
                          _showUniversityPicker();
                        }),
                        const Divider(height: 30, thickness: 1),
                        _editableTile(
                          Icons.email,
                          "Email",
                          user.userEmail ?? '-',
                          null,
                        ),
                        _editableTile(Icons.phone, "Phone", phone, () {
                          _editField(
                            "Phone Number",
                            phone,
                            (val) => setState(() => phone = val),
                          );
                        }),
                        _editableTile(Icons.home, "Room No/Level", address, () {
                          _editField(
                            "Room No/Level",
                            address,
                            (val) => setState(() => address = val),
                          );
                        }),
                        _editableTile(Icons.person, "Name", name, () {
                          _editField(
                            "Full Name",
                            name,
                            (val) => setState(() => name = val),
                          );
                        }),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text("Date Registered"),
                          subtitle: Text(_formatDate(user.userDatereg)),
                        ),
                        const Divider(height: 30, thickness: 1),
                        _editableTile(Icons.money, "Credit", credit, () {
                          _editBuyField(
                            "Credit",
                            credit,
                            (val) => setState(() => credit = val),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider _buildItemImage() {
    return kIsWeb
        ? MemoryImage(webImageBytes!)
        : FileImage(_image!) as ImageProvider;
  }

  void _showUniversityPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Block"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: unilist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(unilist[index]),
                  onTap: () {
                    setState(() {
                      university = unilist[index];
                      updateProfile();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _editableTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onEdit,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing:
          onEdit != null
              ? IconButton(icon: const Icon(Icons.edit), onPressed: onEdit)
              : null,
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      DateTime localDate = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(localDate);
    } catch (_) {
      return '-';
    }
  }

  void _editField(String label, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit $label"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Enter $label"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onSave(controller.text.trim());
                  updateProfile();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  void _editBuyField(
    String label,
    String initialValue,
    Function(String) onSave,
  ) {
    (text: initialValue);

    final List<int> creditOptions = [5, 10, 20, 50];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Buy Credits"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("1 Credit = RM 0.50"),
                ...creditOptions.map((amount) {
                  return ListTile(
                    title: Text("$amount credits"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pop(context); // Close the dialog
                      buyCredit(amount); // Call the buyCredit method
                    },
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  void _changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
      if (webImageBytes != null && webImageBytes!.isNotEmpty) {
        updateProfile();
      }
      // cropImage();

      setState(() {});
    }
  }

  String? getBase64Image() {
    if (kIsWeb && webImageBytes != null) {
      return base64Encode(webImageBytes!);
    } else if (!kIsWeb && _image != null) {
      return base64Encode(_image!.readAsBytesSync());
    }
    return "NA";
  }

  void updateProfile() async {
    final base64Image = getBase64Image();

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}ktargo/php/update_profile.php"),
      body: {
        "userid": widget.user.userId,
        "name": name,
        "phone": phone,
        "address": address,
        "image": base64Image,
        "university": university,
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          widget.user.userName = name;
          widget.user.userPhone = phone;
          widget.user.userAddress = address;
          widget.user.userUniversity = university;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Update failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error. Please try later."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> buyCredit(int amount) async {
    // Navigator.pop(context);
    await Navigator.push(
      context,
      AnimatedRoute.slideFromRight(
        BuyCreditScreen(
          user: widget.user,
          amount: amount,
          currentCredit: int.parse(credit),
          onSuccess: (newCredit) {
            setState(() {
              credit = newCredit.toString();
            });
          },
        ),
      ),
    );
    widget.user.userCredit = credit; // Update user credit
  }
}
