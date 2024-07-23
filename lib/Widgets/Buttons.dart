import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          // Set the button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Customize shape
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor, // Set the text color
            fontSize: 16.0, // Adjust font size as needed
          ),
        ),
      ),
    );
  }
}
