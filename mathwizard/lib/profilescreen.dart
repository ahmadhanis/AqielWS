// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mathwizard/models/user.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController oldpasswordController = TextEditingController();
  String selectedSchool = '';
  bool isLoading = false;
  File? _image;
  String selectedStandard = '1';
  List<Map<String, String>> sarawakSchools = [
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

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.user.fullName.toString();
    selectedSchool = widget.user.schoolCode.toString();
    selectedStandard = widget.user.standard.toString();
  }

  Future<void> _updateProfile() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }
    if (oldpasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password is required.")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      "https://slumberjer.com/mathwizard/api/update_profile.php",
    );
    final request = http.MultipartRequest('POST', url);

    request.fields['user_id'] = widget.user.userId.toString();
    request.fields['old_password'] = oldpasswordController.text.trim();
    request.fields['full_name'] = fullNameController.text.trim();
    request.fields['school_code'] = selectedSchool;
    request.fields['standard'] = selectedStandard;

    if (passwordController.text.isNotEmpty) {
      request.fields['password'] = passwordController.text.trim();
    }

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', _image!.path),
      );
    }

    final response = await request.send();

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseBody =
          json.decode(await response.stream.bytesToString())
              as Map<String, dynamic>;
      if (responseBody['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully.")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseBody['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path); // Convert XFile to File
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _image == null
                                ? NetworkImage(
                                  "https://slumberjer.com/mathwizard/uploads/profile_images/profile_${widget.user.userId}.jpg",
                                )
                                : FileImage(_image!) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name Field
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),

                // School Dropdown
                DropdownButtonFormField<String>(
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
                  },
                  decoration: const InputDecoration(
                    labelText: "Select School",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
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
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Standard",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: oldpasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Current Password (required)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "New Password (Optional)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 30),

                // Update Button
                ElevatedButton(
                  onPressed: isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text(
                            "Update Profile",
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
