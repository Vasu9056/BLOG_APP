import 'package:blog_application/components/buttons.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_snackbars/smart_snackbars.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          _nameController.text = userData['name'];
          _ageController.text = userData['age'].toString();
          // Only set the _imageFile if the photoUrl is not null
          if (userData['photoUrl'] != null && userData['photoUrl'].isNotEmpty) {
            _imageFile = File(userData['photoUrl']);
          }
        });
      } else {
        // Create the document with default values if it doesn't exist
        await _firestore.collection('users').doc(user.uid).set({
          'name': '',
          'age': 0,
          'photoUrl': '',
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = 'Successfully Saved Profile';
    });

    String name = _nameController.text.trim();
    String age = _ageController.text.trim();
    User? user = _auth.currentUser;

    if (user != null) {
      String? photoUrl;
      if (_imageFile != null) {
        try {
          UploadTask uploadTask = _storage
              .ref('user_photos')
              .child('${user.uid}.jpg')
              .putFile(_imageFile!);
          TaskSnapshot snapshot = await uploadTask;
          photoUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to upload image: $e';
          });
          return;
        }
      }

      try {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          await _firestore.collection('users').doc(user.uid).update({
            'name': name,
            'age': int.parse(age),
            if (photoUrl != null) 'photoUrl': photoUrl,
          });
        } else {
          // If the document does not exist, create it
          await _firestore.collection('users').doc(user.uid).set({
            'name': name,
            'age': int.parse(age),
            'photoUrl': photoUrl ?? '',
          });
        }

        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update profile: $e';
        });
      } finally {
        SmartSnackBars.showTemplatedSnackbar(
          context: context,
          backgroundColor: const Color.fromARGB(188, 12, 188, 156),
          leading: Text(
            _errorMessage,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: const Color.fromARGB(188, 12, 188, 156),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lato(
            color: const Color.fromARGB(188, 12, 188, 156),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageFile != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_imageFile!),
                    )
                  else
                    CircleAvatar(
                      backgroundColor:
                          Color.fromARGB(186, 154, 148, 148).withOpacity(1),
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        color:
                            Color.fromARGB(187, 253, 255, 255).withOpacity(1),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(
                      Icons.image,
                      color: const Color.fromARGB(188, 12, 188, 156)
                          .withOpacity(1),
                    ),
                    label: Text(
                      'Change Photo',
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(188, 12, 188, 156)
                            .withOpacity(1),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(187, 0, 0, 0).withOpacity(1),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: const Color.fromARGB(188, 12, 188, 156)
                              .withOpacity(1),
                        ))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(187, 0, 0, 0).withOpacity(1),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: const Color.fromARGB(188, 12, 188, 156)
                              .withOpacity(1),
                        ))),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Buttons(
                    onPressed: _updateProfile,
                    text: "Save",
                    color: const Color.fromARGB(188, 12, 188, 156),
                    textColor: Colors.white,
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
