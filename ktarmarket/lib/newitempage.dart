import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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
        title: const Text('Add New Item'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showImagePickerDialog();
                },
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      image: DecorationImage(
                        image: _image == null
                            ? const AssetImage('assets/images/camera.png')
                            : FileImage(_image!) as ImageProvider<Object>,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Your Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButton(
                value: dropdownvalue,
                underline: const SizedBox(),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: status.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  dropdownvalue = newValue!;
                  print(dropdownvalue);
                  setState(() {});
                },
              ),
              TextField(
                // Add this TextField
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                // Add this TextField
                controller: itemDescriptionController,
                decoration:
                    const InputDecoration(labelText: 'Item Description'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                  onPressed: () {
                    onSubmitItemDialog();
                  },
                  child: const Text('Submit Item')),
            ],
          ),
        ),
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
        ),
      );
      return;
    }

    if (!email.contains('@') && !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email address'),
        ),
      );
      return;
    }

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid phone number'),
        ),
      );
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
        ),
      );
      return;
    }
    // TODO: implement onSubmitItemDialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Submit Item'),
              content: const Text('Are you sure you want to submit this item?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      Navigator.pop(context);
                      insertItem();
                    })
              ]);
        });
  }

  void insertItem() {
    http.post(Uri.parse('http://ktarmarket.slumberjer.com/api/insertitem.php'),
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
            ),
          );
        }
      }
    });
  }

  void showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _selectFromCamera();
                },
              ),
              ListTile(
                title: const Text('Gallery'),
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
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }
    setState(() {});
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    }
    setState(() {});
  }
}
