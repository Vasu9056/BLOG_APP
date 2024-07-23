import 'package:blog_application/Screens/SettingsScreen/Setting_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../ThemeScreen/ThemeProvider_Screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Drawer(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Options',
                  style: GoogleFonts.robotoMono(
                    color: const Color(0xFFEE8206),
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF57636C),
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    !snapshot.data!.exists) {
                  return Column(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User Name',
                        style: GoogleFonts.robotoMono(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'email@example.com',
                        style: GoogleFonts.robotoMono(),
                      ),
                    ],
                  );
                }

                var userData = snapshot.data!;
                String? email = userData.get('email') as String?;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vasu Langdecha', // Replace with userData.get('name') if available
                            style: GoogleFonts.robotoMono(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email ?? 'email@example.com',
                            style: GoogleFonts.robotoMono(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(
              thickness: 1,
              color: Color(0xFFE0E3E7),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFFEE8206),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Profile',
                      style: GoogleFonts.robotoMono(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xFFE0E3E7),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const AccountScreen());
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFFEE8206),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: GoogleFonts.robotoMono(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xFFE0E3E7),
            ),
            GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Color(0xFFEE8206),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Log out',
                      style: GoogleFonts.robotoMono(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xFFE0E3E7),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/publishblog');
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_box_rounded,
                      color: Color(0xFFEE8206),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add new article',
                      style: GoogleFonts.robotoMono(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              color: Color(0xFFE0E3E7),
            ),
            Container(
              padding: const EdgeInsets.only(right: 15),
              margin: const EdgeInsets.only(right: 5),
              child: ListTile(
                title: const Text("Change Theme"),
                leading: const Icon(Icons.dark_mode_outlined),
                onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
