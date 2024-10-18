import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:flutter_svg/svg.dart';
import 'package:rewardrangerapp/screen/signup_screen.dart';
import 'package:rewardrangerapp/widget/elevated_button.dart';

class SignUpOptionsScreen extends StatelessWidget {
  const SignUpOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Sign Up Options',
        ),
      ),
      body: Center(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 15.0.sp), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60.h,
              ),
              SvgPicture.asset(
                "assets/images/Signup.svg",
                height: 300.0.h, // Optional: Set height or width if needed
                width: double.infinity,
              ),
              SizedBox(
                height: 160.h,
              ),
              // First Sign Up Button
              SizedBox(
                width: double.infinity, // Full width
                child: CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SignUpPage(isPhoneAuth: true),
                      ),
                    );
                  },
                  text: 'Sign Up with Phone',
                ),
              ),
              SizedBox(height: 20.h), // Responsive space between buttons

              // Second Sign Up Button
              SizedBox(
                width: double.infinity, // Full width
                child: CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SignUpPage(isPhoneAuth: false),
                      ),
                    );
                  },
                  text: 'Sign Up with Email',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
