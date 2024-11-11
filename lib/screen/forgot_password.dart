import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rewardrangerapp/helper_function/dialog.dart';
import 'package:rewardrangerapp/widget/elevated_button.dart';
import '../helper_function/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final _apiService =
      GetIt.instance<ApiService>(); // Get the ApiService instance

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (_formKey.currentState!.validate()) {
      try {
        // Call the forgotPassword method from ApiService
        final result = await _apiService.forgotPassword(email);
        if (result['status'] == true) {
          if (mounted) {
            DialogUtil.showSuccessSnackbar(
                context, 'Password reset email sent');
            // Navigate to the login screen after showing the success message
            await Future.delayed(
                const Duration(seconds: 2)); // Optional delay for visibility
            Navigator.of(context).pop(); // Pop the current screen
          }
        } else {
          if (mounted) {
            DialogUtil.showErrorSnackbar(
                context, 'Failed to send password reset email');
          }
        }
      } catch (e) {
        if (mounted) {
          DialogUtil.showErrorSnackbar(context, 'An error occurred: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp), // Responsive padding
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8.0.sp), // Responsive border radius
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h), // Responsive height
              SizedBox(
                width: double.infinity, // Full width button
                child: CustomElevatedButton(
                  onPressed: _resetPassword,
                  text: 'Reset Password',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
