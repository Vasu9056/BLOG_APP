import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = false;

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.orange,
      brightness: Brightness.light,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.orange, // Default button color for light mode
      ),
      // Define other theme attributes here
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.orange,
      brightness: Brightness.dark,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.black, // Default button color for dark mode
      ),
    
    );
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
