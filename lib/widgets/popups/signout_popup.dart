import 'package:codeshield/screens/login_menu.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/core/app_text_styles.dart';

void showSignOutPopup(BuildContext context) {
  // Get screen width to calculate relative size
  final screenWidth = MediaQuery.of(context).size.width;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        // Ensure the dialog doesn't hug the curved edges of the Tecno screen
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          // Use 85% of screen width instead of a fixed 400
          width: screenWidth * 0.85,
          padding: const EdgeInsets.all(24), 
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("SIGN OUT?", style: AppTextStyles.buttonLabel),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("NO", 
                      style: AppTextStyles.buttonLabel.copyWith(
                        decoration: TextDecoration.underline,
                        fontSize: 18, // Adjusted for mobile readability
                      )),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: Text("YES", 
                      style: AppTextStyles.buttonLabel.copyWith(
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                      )),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}