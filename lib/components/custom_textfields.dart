import 'package:flutter/material.dart';

class CustomTextfields extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final IconData? Icons;
  const CustomTextfields(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.Icons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          hintStyle: TextStyle(color: Colors.grey[800]),
          labelText: hintText,
          prefixIcon: Icons != null
              ? Icon(
                  Icons,
                  color: Colors.green,
                )
              : null,
          enabledBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              const OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
