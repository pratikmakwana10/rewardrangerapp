import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return SizedBox(
      width: double.infinity, // Full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(20, 34, 74, 1),
          padding: EdgeInsets.symmetric(
            horizontal: 16.sp, // Responsive horizontal padding
            vertical: 8.sp, // Responsive vertical padding
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8.sp), // Responsive border radius
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp, // Responsive font size
            letterSpacing: 1.5,
            fontFamily: 'LucidaSans', // Custom font family
          ),
        ),
      ),
    );
  }
}
