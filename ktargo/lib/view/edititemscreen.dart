// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktargo/model/item.dart';
import 'package:ktargo/model/user.dart';
import 'package:ktargo/shared/myconfig.dart';
import 'package:http/http.dart' as http;

class EditItemScreen extends StatefulWidget {
  final User user;
  final Item item;

  const EditItemScreen({super.key, required this.user, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final itemController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  File? _image;
  Uint8List? webImageBytes;

  String delivery = "Postage";
  String itemStatus = "New";
  String itemQty = "1";
  late double screenHeight, screenWidth;
  final deliveryOptions = ['Delivery', 'Pickup'];
  final itemStatusOptions = ['Used', 'New', 'Refurbished', 'Damaged'];
  final qtyOptions = List.generate(10, (index) => '${index + 1}');

  @override
  void initState() {
    super.initState();
    itemController.text = widget.item.itemName ?? '';
    descController.text = widget.item.itemDesc ?? '';
    priceController.text = widget.item.itemPrice ?? '';
    delivery = widget.item.itemDelivery ?? 'Delivery';
    itemStatus = widget.item.itemStatus ?? 'Used';
    itemQty = widget.item.itemQty ?? '1';
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text("Edit Item"),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 800 ? 600 : double.infinity;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: showSelectionDialog,
                            child:
                                _image != null
                                    ? Image(
                                      image: _buildItemImage(),
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    )
                                    : Image.network(
                                      "${MyConfig.myurl}uploads/assets/images/items/item-${widget.item.itemId}.png?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Image.asset(
                                          "assets/images/unigo.png",
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                        );
                                      },
                                    ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            itemController,
                            "Item Name",
                            TextInputType.text,
                          ),
                          _buildTextField(
                            descController,
                            "Item Description",
                            TextInputType.text,
                            maxLines: 4,
                          ),
                          _buildTextField(
                            priceController,
                            "Price (MYR)",
                            TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: delivery,
                            decoration: const InputDecoration(
                              labelText: "Delivery Method",
                              border: OutlineInputBorder(),
                            ),
                            items:
                                deliveryOptions.map((String value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (val) => setState(() => delivery = val!),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: itemStatus,
                                  decoration: const InputDecoration(
                                    labelText: "Item Status",
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      itemStatusOptions.map((String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged:
                                      (val) =>
                                          setState(() => itemStatus = val!),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  value: itemQty,
                                  decoration: const InputDecoration(
                                    labelText: "Quantity",
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      qtyOptions.map((String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged:
                                      (val) => setState(() => itemQty = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.update),
                              label: const Text("Update Item"),
                              onPressed: updateItemDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Select Image From"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _selectFromCamera();
                  },
                  child: const Text("Camera"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _selectFromGallery();
                  },
                  child: const Text("Gallery"),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();

      // cropImage();

      setState(() {});
    }
  }

  ImageProvider _buildItemImage() {
    return kIsWeb
        ? MemoryImage(webImageBytes!)
        : FileImage(_image!) as ImageProvider;
  }

  String? getBase64Image() {
    if (kIsWeb && webImageBytes != null) {
      return base64Encode(webImageBytes!);
    } else if (!kIsWeb && _image != null) {
      return base64Encode(_image!.readAsBytesSync());
    }
    return null;
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
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
      cropImage();
    }
  }

  void updateItemDialog() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.user.userCredit == "0") {
      _showSnackbar("You need to top up your credit first.", color: Colors.red);
      return;
    }
    final priceText = priceController.text.trim();

    final price = double.tryParse(priceText);
    if (price == null) {
      _showSnackbar("Please enter a valid number for price.");
      return;
    }
    if (price <= 0) {
      _showSnackbar("Price must be greater than zero.");
      return;
    }
    if (priceText.isEmpty) {
      _showSnackbar("Price is required.");
      return;
    }
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              "1 credit will be deducted.\nAre you sure you want to Update Item?",
            ),
            content: const Text("Are you sure you want to save changes?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  updateItem();
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  void updateItem() async {
    var base64Image = _image != null ? getBase64Image() : "NA";

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}api/update_item.php"),
      body: {
        "itemid": widget.item.itemId.toString(),
        "name": itemController.text,
        "description": descController.text,
        "status": itemStatus,
        "quantity": itemQty,
        "image": base64Image,
        "userid": widget.user.userId.toString(),
        "delivery": delivery,
        "price": priceController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        _showSnackbar("Item updated successfully", color: Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackbar("Failed to update item");
      }
    } else {
      _showSnackbar("Server error. Please try again later.");
    }
  }

  void _showSnackbar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Please Crop Your Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      setState(() {});
    }
  }
}
