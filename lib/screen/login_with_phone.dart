import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:rewardrangerapp/helper_function/utility.dart';
import 'package:rewardrangerapp/screen/dashboard_screen.dart';
import 'package:rewardrangerapp/screen/otp_veridication.dart';
import 'package:rewardrangerapp/widget/elevated_button.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({super.key});

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PhoneNumber? _phoneNumber; // Variable to store the selected phone number

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool isValidPhoneNumber(String phoneNumber) {
    // Regular expression to match E.164 format
    final RegExp regex = RegExp(r'^\+\d{1,3}\d{10,15}$');
    logger.f(phoneNumber);
    return regex.hasMatch(phoneNumber);
  }

  Future<void> _login() async {
    // Use the phone number from the _phoneNumber object, ensuring it's in E.164 format
    String phoneNumber = _phoneNumber?.phoneNumber ?? '';
    logger.f(phoneNumber);
    // Validate the phone number
    if (!isValidPhoneNumber(phoneNumber)) {
      logger.e("Invalid phone number: $phoneNumber");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter a valid phone number in E.164 format.')),
      );
      return;
    }

    try {
      print('👾 Attempting to verify phone number: $phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print(
              '🔐 Verification completed automatically: ${credential.smsCode}');
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          print(
              '📩 Code sent to $phoneNumber, verification ID: $verificationId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Auto-retrieval timeout, verification ID: $verificationId');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Auto-retrieval timed out. Please enter the OTP manually.')),
          );
        },
      );
    } catch (e) {
      print('⚠️ Error during phone number verification: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Phone'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp), // Responsive padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _phoneNumber = number; // Store the selected phone number
                  });
                },
                selectorTextStyle: const TextStyle(color: Colors.black),
                textFieldController: _phoneNumberController,
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.sp),
                  ),
                  labelText: 'Phone Number',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0.sp),
                  hintText: 'Enter your phone number',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                  showFlags: true,
                  useEmoji: true,
                ),
                initialValue: PhoneNumber(isoCode: 'IN'), // Default to India
                formatInput: false,
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(height: 20.h), // Responsive height
            CustomElevatedButton(
              onPressed: _login,
              text: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}
