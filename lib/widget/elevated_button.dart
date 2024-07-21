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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity, // Make the button full width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Colors.cyan, Colors.purple], // Bright cyan and purple gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(1.5), // Adjust the padding as needed
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 6, 119, 119),
                Colors.purpleAccent,
              ], // Adjust colors as needed
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(28.5), // Adjust to be slightly smaller than the outer radius
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0), // Adjust horizontal padding as needed
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.5), // Adjust to match the inner radius
              ),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: const TextStyle(
                // color: Colors.black,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 16, letterSpacing: 1.3,
                fontFamily: 'LucidaSans', // Use the custom font family
              ),
            ),
          ),
        ),
      ),
    );
  }
}
