import 'package:blog_application/Screens/ResetPassword.dart';
import 'package:blog_application/Screens/Signup.dart';
import 'package:blog_application/Screens/setting_screen.dart';
import 'package:blog_application/Screens/dashboard.dart';
import 'package:blog_application/Screens/profile_screen.dart';
import 'package:blog_application/Screens/login.dart';
import 'package:blog_application/Screens/publish_Blog.dart';
import 'package:blog_application/Screens/splash.dart';
import 'package:blog_application/pages/auth_page.dart';
import 'package:blog_application/theme/theme_provider.dart';
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
