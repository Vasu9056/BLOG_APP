import 'package:flutter/material.dart';

class Blocks extends StatelessWidget {
  final String imagepath;
  final Function()? ontap;

  const Blocks({super.key, required this.imagepath, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 31, 30, 30),
        ),
        child: Image.asset(
          imagepath,
          height: 40,
        ),
      ),
    );
  }
}
