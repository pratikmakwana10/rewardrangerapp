import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rewardrangerapp/helper_function/api_service.dart';
import 'package:rewardrangerapp/screen/login_screen.dart';

import '../helper_function/utility.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final ApiService _apiService = GetIt.instance<ApiService>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> userData = {
        "email": _emailController.text,
        "password": _passwordController.text,
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "gender": _genderController.text,
        "dob": _dobController.text,
        "city": _cityController.text,
      };

      logger.i('Submitting data: $userData');

      try {
        final response = await _apiService.signUp(userData);
        if (response['status'] == true) {
          logger.i('Sign up successful: ${response['message']}');
          _showSuccessSnackbar(response['message']);
          // Navigate to the login page
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        } else {
          logger.i('Sign up failed: ${response['message']}');
          _showErrorSnackbar(response['message']);
        }
      } catch (e) {
        logger.i('Sign up failed: $e');

        _showErrorSnackbar(e.toString());
      }
    } else {
      logger.e('Form validation failed');
    }
  }

  void _showSuccessSnackbar(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Example:
  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 9, 81, 115),
              Color.fromARGB(255, 57, 106, 252),
              Color.fromARGB(255, 151, 8, 254),
              Color.fromARGB(193, 110, 14, 166),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 45,
                ),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _genderController,
                  labelText: 'Gender (M/F)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your gender';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _dobController,
                  labelText: 'Date of Birth (DD-MM-YYYY)',
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _cityController,
                  labelText: 'City',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.7), width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text('Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to login screen
                    // Example:
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const Login()));
                  },
                  child: const Text('Already have an account? Log in',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    required FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle:
              const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.7)), // White with 70% opacity
          enabledBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(255, 255, 255, 0.7)), // White with 70% opacity
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // White color for focused border
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
