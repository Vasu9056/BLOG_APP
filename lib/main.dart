import 'package:blog_application/Screens/HomeScreen/Dashboard_Screen.dart';
import 'package:blog_application/Screens/LoginScreens/ResetPassword_Screen.dart';
import 'package:blog_application/Screens/SignupScreen/Signup_Screen.dart';
import 'package:blog_application/Screens/SettingsScreen/Setting_Screen.dart';
import 'package:blog_application/Screens/ProfileScreens/Profile_Screen.dart';
import 'package:blog_application/Screens/LoginScreens/Login_Screen.dart';
import 'package:blog_application/Screens/BlogsScreen/PublishBlog_Screen.dart';
import 'package:blog_application/Screens/Splash_Screen.dart';
import 'package:blog_application/Services/auth_page.dart';
import 'package:blog_application/ThemeScreen/ThemeProvider_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const startupscreen(),
    ),
  );
}

class startupscreen extends StatefulWidget {
  const startupscreen({super.key});

  @override
  State<startupscreen> createState() => _startupscreenState();
}

// ignore: camel_case_types
class _startupscreenState extends State<startupscreen> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        "/": (context) => const Splash(),
        "/checkuser": (context) => const AuthPage(),
        "/login": (context) => const LoginScreen(),
        "/Signup": (context) => SignUpScreen(),
        "/dashboard": (context) => const Dashboard(),
        "/publishblog": (context) => const PublishBlog(),
        "/Forgetpassword": (context) => const Resetpassword(),
        '/profile': (context) => const EditAccountScreen(),
        '/account_screen': (context) => const AccountScreen(),
      },
    );
  }
}
