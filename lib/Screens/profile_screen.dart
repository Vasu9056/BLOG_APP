import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../theme/theme_provider.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _emailController.text = user!.email ?? '';
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _ageController.text = data['age'] ?? '';
      _phoneController.text = data['phone'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': _nameController.text,
      'age': _ageController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    });

    if (_imageFile != null) {
      // Upload image to Firebase Storage and get the URL
      // Then update Firestore document with the image URL
    }

    if (_passwordController.text.isNotEmpty) {
      try {
        await user!.updatePassword(_passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Color(0xFFEE8206)),
        title: Text(
          'Profile',
          style: GoogleFonts.robotoMono(
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : null,
                    child: _imageFile == null
                        ? const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 50,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Change/Upload Image',
                  style: GoogleFonts.robotoMono(
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField('Name:', _nameController, isDarkMode),
                const SizedBox(height: 16),
                _buildTextField('Age:', _ageController, isDarkMode,
                    inputType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField('Email:', _emailController, isDarkMode,
                    inputType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Phone:', _phoneController, isDarkMode,
                    inputType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(
                    'New Password:', _passwordController, isDarkMode,
                    inputType: TextInputType.visiblePassword,
                    obscureText: true),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.black : Colors.black,
                          foregroundColor:
                              isDarkMode ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Discard',
                          style: GoogleFonts.robotoMono(
                            color: isDarkMode ? Colors.white : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE8206),
                          foregroundColor:
                              Colors.black, // Text color for Save button
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool isDarkMode,
      {TextInputType inputType = TextInputType.text,
      bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: isDarkMode ? Colors.grey : Colors.white,
          ),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ],
    );
  }
}
