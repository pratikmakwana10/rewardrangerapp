import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import '../helper_function/api_service.dart'; // Import your ApiService
import '../helper_function/dialog.dart';
import '../widget/text_field.dart';

class ContactSupport extends StatelessWidget {
  const ContactSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(context,
        designSize: const Size(375, 812), minTextAdapt: true);

    final TextEditingController controller = TextEditingController();
    final ApiService apiService = ApiService(); // Instantiate your ApiService

    void handleSubmit() async {
      // Validate the form (if needed)
      if (controller.text.isEmpty) {
        DialogUtil.showErrorSnackbar(context, 'Please enter your message');
        return;
      }

      // Call the userQuery API method
      try {
        final response = await apiService.userQuery(controller.text);
        // Handle the response as needed (e.g., show result in UI)
        DialogUtil.showSuccessSnackbar(context, 'User query successful');
      } catch (e) {
        DialogUtil.showErrorSnackbar(
            context, 'Failed to perform user query: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 219, 11, 11),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.w), // Use ScreenUtil for padding
                child: SizedBox(
                  height: 300.h, // Use ScreenUtil for height
                  child: CustomTextField(
                    controller: controller,
                    labelText: 'Enter your message',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding:
                EdgeInsets.only(bottom: 20.h), // Use ScreenUtil for padding
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: handleSubmit, // Call handleSubmit function
                child: Text('Submit',
                    style: TextStyle(
                        fontSize: 16.sp)), // Use ScreenUtil for text size
              ),
            ),
          ),
        ],
      ),
    );
  }
}
