import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(
      //   horizontal: 10,
      // ),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(20, 34, 74, 1),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8), // Horizontal padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            // color: Colors.black,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            fontSize: 16, letterSpacing: 1.5,
            fontFamily: 'LucidaSans', // Use the custom font family
          ),
        ),
      ),
    );
  }
}
