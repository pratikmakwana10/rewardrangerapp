import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:rewardrangerapp/screen/signup_option.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/contact_support.dart';

class DrawerScreen extends StatelessWidget {
  final String firstName;
  final String lastName;

  const DrawerScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(223, 6, 0, 42),
      padding: EdgeInsets.all(16.0.sp), // Responsive padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50.h), // Responsive height
          CircleAvatar(
            radius: 50.sp, // Responsive radius
            backgroundColor: const Color.fromARGB(99, 27, 9, 184),
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.sp, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.h), // Responsive height
          Text(
            firstName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp, // Responsive font size
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h), // Responsive height
          const Text(
            'user@example.com',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Spacer(),
          _buildListTile(Icons.support, 'Contact Support', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactSupport()),
            );
          }),
          SizedBox(height: 30.h), // Responsive height
          _buildListTile(Icons.person_add, 'Refer and Earn', () {
            // Handle refer and earn action
          }),
          const Spacer(),
          _buildListTile(
            Icons.logout_rounded,
            'Log Out',
            () {
              _logout(context);
              // Handle logout action
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    // Get the instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove the stored token
    await prefs.remove('token');

    // Optionally, navigate to the login screen or another appropriate screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SignUpOptionsScreen()), // Replace with your actual login screen widget
    );

    // Optionally, show a message or log out action for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }

  Widget _buildListTile(IconData icon, String text, void Function()? onTap,
      {Color? textColor}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.sp), // Responsive border radius
        border: Border.all(
          color: const Color.fromARGB(255, 0, 234, 255),
          width: 0.7.sp, // Responsive border width
        ),
      ),
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 25.sp), // Responsive padding
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 0, 234, 255),
              size: 30.sp, // Responsive icon size
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 45.sp), // Responsive padding
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.sp, // Responsive font size
              color: textColor ?? const Color.fromARGB(255, 0, 234, 255),
              letterSpacing: 2,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
