import 'package:blog_application/Screens/LoginScreens/ResetPassword_Screen.dart';
import 'package:blog_application/Screens/LoginScreens/Otp_login_Screen.dart';
import 'package:blog_application/Services/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_snackbars/smart_snackbars.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _errorMessage = '';
  bool _obscurePassword = true;

  void _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _storeUserEmail(userCredential.user!.email!);
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/dashboard');

        SmartSnackBars.showTemplatedSnackbar(
          // ignore: use_build_context_synchronously
          context: context,
          backgroundColor: const Color.fromARGB(187, 9, 120, 35),
          leading: Flexible(
            child: Text(
              "Login successful for: ${userCredential.user!.email}",
              style: GoogleFonts.lato(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _showErrorSnackbar("No user found for that email.");
            break;
          case 'wrong-password':
            _showErrorSnackbar("Wrong password provided for that user.");
            break;
          case 'invalid-email':
            _showErrorSnackbar("The email address is not valid.");
            break;
          default:
            _showErrorSnackbar('An error occurred. Please try again later.');
        }
      });
    } catch (e) {
      _showErrorSnackbar(
          'An unexpected error occurred. Please try again later.');
    }
  }

  void _showErrorSnackbar(String message) {
    SmartSnackBars.showTemplatedSnackbar(
      context: context,
      backgroundColor: const Color.fromARGB(187, 9, 120, 35).withOpacity(1),
      leading: Flexible(
        child: Text(
          message,
          style: GoogleFonts.lato(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _storeUserEmail(String userEmail) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'email': userEmail,
      }
          // SmartSnackBars.showTemplatedSnackbar(
          //   // ignore: use_build_context_synchronously
          //   context: context,
          //   backgroundColor: const Color.fromARGB(188, 12, 188, 156).withOpacity(1),
          //   leading: Flexible(
          //     child: Text(
          //       'User email stored in Firestore: $userEmail',
          //       style: GoogleFonts.lato(
          //         fontSize: 15,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          );
    } catch (e) {
      SmartSnackBars.showTemplatedSnackbar(
        // ignore: use_build_context_synchronously
        context: context,
        backgroundColor: const Color.fromARGB(188, 12, 188, 156).withOpacity(1),
        leading: Flexible(
          child: Text(
            'Error storing user email: $e',
            style: GoogleFonts.lato(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _loginWithGoogle() async {
    try {
      await GoogleAuth().signInWithGoogle();
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/dashboard');
      _showSuccessSnackbar("Google login successful", Colors.blue);
    } catch (e) {
      _showErrorSnackbar('Google login failed. Please try again.');
    }
  }

  void _showSuccessSnackbar(String message, Color color) {
    SmartSnackBars.showTemplatedSnackbar(
      context: context,
      backgroundColor: color,
      leading: Flexible(
        child: Text(
          message,
          style: GoogleFonts.lato(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.15),
              Image.asset(
                'assets/login.png',
                height: screenHeight * 0.3,
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                    color: const Color(0xFFEE8206),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenWidth * 0.1),
                      topRight: Radius.circular(screenWidth * 0.1),
                      bottomLeft: Radius.circular(screenWidth * 0.02),
                      bottomRight: Radius.circular(screenWidth * 0.02),
                    )),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    children: [
                      _buildErrorMessage(),
                      SizedBox(height: screenHeight * 0.05),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            color: Colors.black,
                            margin: EdgeInsets.only(right: screenWidth * 0.03),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.only(left: screenWidth * 0.03),
                          hintText: 'Username...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            color: Colors.black,
                            margin: EdgeInsets.only(right: screenWidth * 0.03),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.only(left: screenWidth * 0.03),
                          hintText: 'Password...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.to(() => const Resetpassword());
                              },
                              child: Text(
                                "Forgot Password",
                                style: GoogleFonts.lato(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize:
                              Size(double.infinity, screenHeight * 0.07),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color.fromARGB(255, 143, 139, 139),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color.fromARGB(255, 143, 139, 139),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _loginWithGoogle,
                            child: CircleAvatar(
                              radius: screenWidth * 0.05,
                              backgroundImage:
                                  const AssetImage("assets/google.jpg"),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.05,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ForgotPasswordScreen());
                            },
                            child: CircleAvatar(
                              radius: screenWidth * 0.05,
                              backgroundImage:
                                  const AssetImage("assets/call.jpg"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'New User?',
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/Signup');
                            },
                            child: Text(
                              'Signup',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 6, 88, 32),
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _errorMessage,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
