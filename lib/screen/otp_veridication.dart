import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rewardrangerapp/screen/dashboard_screen.dart';

class EnterOtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const EnterOtpScreen({
    required this.verificationId,
    required this.phoneNumber,
    super.key,
  });

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false; // Loading state variable

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final String otp = _otpController.text;

    if (otp.isEmpty) {
      // Handle empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      setState(() {
        _isLoading = false; // Stop loading
      });
      return;
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Navigate to dashboard or home screen on successful sign-in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      // Handle error with detailed messages
      String errorMessage = 'Failed to sign in';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            errorMessage = 'Invalid OTP. Please try again.';
            break;
          case 'session-expired':
            errorMessage = 'Session expired. Please retry.';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp), // Responsive padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTextFormField(
              controller: _otpController,
              labelText: 'OTP',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.h), // Responsive height
            _isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity,
                          50.h), // Full width, responsive height
                    ),
                    child: const Text('Verify OTP'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 8.0.h), // Responsive vertical padding
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10.0.sp), // Responsive border radius
          ),
          labelText: labelText,
        ),
        validator: validator,
      ),
    );
  }
}
