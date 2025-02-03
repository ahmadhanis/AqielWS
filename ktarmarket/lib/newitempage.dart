// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Uint8List? _webImage; // Store image for Web
  var status = [
    'New',
    'Used',
  ];
  String dropdownvalue = 'New';

  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centers the title for a cleaner look
        elevation: 4, // Adds a shadow effect
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple,
                Colors.purpleAccent
              ], // Modern gradient colors
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double formWidth = constraints.maxWidth > 600
              ? 500
              : double.infinity; // Adjust form width for larger screens

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // 🖼️ Responsive Image Picker

                    GestureDetector(
                      onTap: showImagePickerDialog,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Adaptive height based on screen size
                          double containerHeight = constraints.maxWidth > 1200
                              ? 500 // Desktop: Larger image container
                              : constraints.maxWidth > 600
                                  ? 350 // Tablet: Medium image container
                                  : 250; // Mobile: Smaller image container

                          return Container(
                            height: containerHeight,
                            width: constraints.maxWidth *
                                0.9, // 90% width for responsiveness
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black54, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _image == null && _webImage == null
                                ? const Center(
                                    child: Icon(Icons.camera_alt,
                                        size: 80, color: Colors.black54),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.memory(
                                            _webImage!, // Display web image
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                        : Image.file(
                                            _image!, // Display mobile/desktop image
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                  ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📜 Email Input
                    Card(
                      elevation: 3,
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Your Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 📞 Phone Input
                    Card(
                      elevation: 3,
                      child: TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔽 Status Dropdown
                    Card(
                      elevation: 3,
                      child: DropdownButtonFormField<String>(
                        value: dropdownvalue,
                        decoration: const InputDecoration(
                          labelText: 'Item Condition',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: status.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 📦 Item Name Input
                    Card(
                      elevation: 3,
                      child: TextField(
                        controller: itemNameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_bag),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 📝 Item Description Input
                    Card(
                      elevation: 3,
                      child: TextField(
                        controller: itemDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Item Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 💰 Price Input
                    Card(
                      elevation: 3,
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (RM)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📤 Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onSubmitItemDialog,
                        icon: const Icon(Icons.upload),
                        label: const Text('Submit Item'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void onSubmitItemDialog() {
    String email = emailController.text;
    String phone = phoneController.text;
    String status = dropdownvalue;
    String itemName = itemNameController.text;
    String itemDescription = itemDescriptionController.text;
    String price = priceController.text;

    if (email.isEmpty || phone.isEmpty || itemName.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!email.contains('@') && !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email address'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // TODO: implement onSubmitItemDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📌 Title
                const Text(
                  'Submit Item',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 📝 Content
                const Text(
                  'Are you sure you want to submit this item?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // 🔘 Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ❌ Cancel Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
                    ),

                    // ✅ Submit Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        insertItem();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Submit',
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
  }

  void insertItem() {
    http.post(Uri.parse('https://ktarmarket.slumberjer.com/api/insertitem.php'),
        body: {
          'email': emailController.text,
          'phone': phoneController.text,
          'status': dropdownvalue,
          'itemName': itemNameController.text,
          'itemDescription': itemDescriptionController.text,
          'price': priceController.text,
          'image': base64Encode(_image!.readAsBytesSync()),
        }).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text('Success'),
                    content: const Text(
                        'Please check your email for item verification'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      )
                    ]);
              });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit item'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });
  }

  void showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📌 Title
              const Text(
                'Choose Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 📸 Camera Option
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.purple),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromCamera();
                },
              ),

              // 🖼️ Gallery Option
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();

    if (kIsWeb) {
      // 🌍 Web: Open File Picker Instead of Camera
      final XFile? pickedFile = await picker.pickImage(
        source:
            ImageSource.gallery, // Web does not support direct camera access
        maxHeight: 800,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        _webImage =
            await pickedFile.readAsBytes(); // Convert to Uint8List for Web
        setState(() {}); // Refresh UI
      }
    } else {
      // 📱 Mobile & Desktop: Use Camera
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {}); // Refresh UI
      }
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();

    if (kIsWeb) {
      // 🌍 Web: Use `image_picker_for_web` to select an image
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        _webImage =
            await pickedFile.readAsBytes(); // Convert web image to Uint8List
        setState(() {}); // Refresh UI
      }
    } else {
      // 📱 Mobile & Desktop: Select from Gallery
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {}); // Refresh UI
      }
    }
  }
}
