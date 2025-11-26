import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class UpdatePasswordScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Update your password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'By updating your password, you can ensure the security of your account.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            // Password Text Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18.0,
                  horizontal: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle password update action
                  final password = _passwordController.text;
                  if (password.isNotEmpty) {
                    // Update password logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid password')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
