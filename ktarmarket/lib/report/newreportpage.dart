import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewReportPage extends StatefulWidget {
  const NewReportPage({super.key});

  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController titleReportController = TextEditingController();
  TextEditingController reportDescriptionController = TextEditingController();
  Uint8List? _webImage;
  File? _image;
  var buildings = [
    'Block A',
    'Block B',
    'Block C',
    'Block D',
    'Block E',
    'Mosque',
    'HEP'
  ];
  String dropdownbuilding = 'Block A';

  var reporttype = [
    'Item Missing',
    'Item Damaged',
    'Item Stolen',
    'Electrical',
    'Other'
  ];
  String dropdownvalue = 'Item Missing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  showImagePickerDialog();
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 250,
                  decoration: BoxDecoration(border: Border.all()),
                  child: _image == null
                      ? const Center(
                          child: Icon(
                          Icons.camera_alt,
                          size: 150,
                          color: Colors.purple,
                        ))
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                )),
            const SizedBox(height: 16),
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
                  labelText: 'Report Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: reporttype.map((String value) {
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

            Card(
              elevation: 3,
              child: DropdownButtonFormField<String>(
                value: dropdownbuilding,
                decoration: const InputDecoration(
                  labelText: 'Building Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: buildings.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownbuilding = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              child: TextField(
                controller: titleReportController,
                decoration: const InputDecoration(
                  labelText: 'Report Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 📝 Item Description Input
            Card(
              elevation: 3,
              child: TextField(
                controller: reportDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Report Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 12),

            // 📌 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmitReportDialog,
                icon: const Icon(Icons.upload),
                label: const Text('Submit Report'),
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
    );
  }

  void onSubmitReportDialog() {
    String email = emailController.text;
    String phone = phoneController.text;
    String titleReport = titleReportController.text;
    String reportDescription = reportDescriptionController.text;

    if (email.isEmpty ||
        phone.isEmpty ||
        titleReport.isEmpty ||
        reportDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
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
    //disini paste
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
                  'Submit Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 📝 Content
                const Text(
                  'Are you sure you want to submit this report?',
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
                        insertReport();
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

  void insertReport() {
    http.post(
        Uri.parse('https://ktarmarket.slumberjer.com/api/insertreport.php'),
        body: {
          'email': emailController.text,
          'phone': phoneController.text,
          'type': dropdownvalue,
          'block': dropdownbuilding,
          'title': titleReportController.text,
          'description': reportDescriptionController.text,
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
}
