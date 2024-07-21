import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          // Outer border
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), // Outer radius
              border: Border.all(color: Colors.greenAccent, width: 1.5), // Outer border color
            ),
            child: Container(
              padding: const EdgeInsets.all(2.0), // Padding for inner border thickness
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.5), // Inner radius slightly smaller
                border: Border.all(color: Colors.blueAccent, width: 2.0), // Inner border color
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(28.5), // Match inner container's border radius
                  color: Colors.transparent, // Transparent background for the inner container
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blueAccent, Colors.greenAccent], // Gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent, // Transparent background for the text field
                      labelText: "    $labelText",
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(0, 57, 19,
                            230), // Set to transparent so ShaderMask can apply the gradient
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none, // No border color
                        borderRadius: BorderRadius.circular(30), // Match outer border radius
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none, // No border color
                        borderRadius: BorderRadius.circular(30), // Match outer border radius
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    validator: validator,
                    onTap: onTap,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
