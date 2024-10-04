import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId; // Variable to store verification ID
  PhoneNumber? _phoneNumber; // Variable to store the selected phone number

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_phoneNumber == null || _phoneNumber!.phoneNumber!.isEmpty) {
      // Handle empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    try {
      String fullPhoneNumber = '${_phoneNumber!.phoneNumber}';
      logger.f('${_phoneNumber!.phoneNumber}');
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          // Navigate to dashboard or home screen on successful sign-in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to verify phone number: ${e.message}'),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          // Navigate to OTP input screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnterOtpScreen(
                verificationId: _verificationId!,
                phoneNumber: _phoneNumber!.phoneNumber!,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      // Handle exceptions
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _phoneNumber = number;
                  });
                },
                selectorTextStyle: const TextStyle(color: Colors.white),
                textFieldController: _phoneController,
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  labelText: 'Phone Number',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  hintText: 'Enter your phone number',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                  showFlags: true,
                  useEmoji: true,
                ),
                initialValue: PhoneNumber(isoCode: 'IN'),
                formatInput: false,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 20),
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
