import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dashboard/widgets/profile/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({Key? key}) : super(key: key);

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _selectedImage;
  bool _showOptions = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bloodInformationController =
      TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
  }

  Future<void> saveDetails() async {
    try {
      final User? user = _auth.currentUser;
      final String uid = user!.uid;

      String? imageUrl;
      if (_selectedImage != null) {
        final Reference storageRef =
            FirebaseStorage.instance.ref().child('profilePictures').child(uid);
        final UploadTask uploadTask = storageRef.putFile(_selectedImage!);
        final TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await _firestore.collection('doctors').doc(uid).set(
        {
          'profilePicture': imageUrl,
          'doctorName': _nameController.text.trim(),
          'weight': _weightController.text.trim(),
          'height': _heightController.text.trim(),
          'bloodInformation': _bloodInformationController.text.trim(),
        },
        SetOptions(merge: true),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Profile(),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 100),
                  child: const Column(
                    children: [
                      Text(
                        "My Username & Photo",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(top: 200),
                        width: 400,
                        height: 600,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                      image: _selectedImage != null
                                          ? DecorationImage(
                                              image: FileImage(_selectedImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 14,
                                          bottom: 14,
                                          child: IconButton(
                                            onPressed: _toggleOptions,
                                            icon: const Icon(Icons.camera_alt),
                                            iconSize: 30,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                            Column(
                              children: [
                                TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Doctor name",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 139, 136, 136),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                TextField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Weight",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 139, 136, 136),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                TextField(
                                  controller: _heightController,
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "height",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 139, 136, 136),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                TextField(
                                  controller: _bloodInformationController,
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Blood Type",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 139, 136, 136),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Icon(Icons.arrow_back_ios),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        saveDetails();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child:
                                          const Icon(Icons.arrow_forward_ios),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showOptions)
                GestureDetector(
                  onTap: _toggleOptions,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Upload Options',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _pickImage(ImageSource.camera);
                                _toggleOptions();
                              },
                              icon: const Icon(Icons.photo_camera),
                              label: const Text('Take a Photo'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                _pickImage(ImageSource.gallery);
                                _toggleOptions();
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Choose from Gallery'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ImageUploadPage(),
  ));
}
