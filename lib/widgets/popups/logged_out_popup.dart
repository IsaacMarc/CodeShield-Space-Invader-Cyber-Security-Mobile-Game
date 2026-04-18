import 'package:codeshield/screens/login_menu.dart';
import 'package:codeshield/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_text_styles.dart';

void showLoggedOutPopup(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  showDialog(
    context: context,
    builder: (context) {
      // Reusable transition for the snappy "Cyber" feel
      Route _createCyberRoute(Widget page) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutExpo;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      }

      Widget rowActionButtons = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).push(_createCyberRoute(const LoginPage())),
            child: Text(
              "LOGIN",
              style: AppTextStyles.buttonLabel.copyWith(
                decoration: TextDecoration.underline,
                fontSize: 18, // Adjusted for the 1080p density
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(_createCyberRoute(const RegisterPage())),
            child: Text(
              "REGISTER",
              style: AppTextStyles.buttonLabel.copyWith(
                decoration: TextDecoration.underline,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );

      Widget dialogTitleBox = SizedBox(
        height: 60, 
        child: Stack(
          // We remove the stack-level alignment and let the children define their spots
          children: [
            // 1. Title: Centered perfectly
            const Center(
              child: Text(
                "LOGGED OUT", 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 20, 
                  fontFamily: 'PixelifySans' // or your AppTextStyles
                ),
              ),
            ),

            // 2. Close Button: Forced to the top-right corner
            Positioned(
              top: 0,
              right: 0, 
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Image.asset(
                  AppIcons.close,
                  width: 40,
                  filterQuality: FilterQuality.none,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Removes default padding
              ),
            ),
          ],
        ),
      );

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Colors.transparent,
        child: Container(
          // Responsive width for the Tecno screen
          width: screenWidth * 0.45,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dialogTitleBox,
              const SizedBox(height: 20),
              rowActionButtons,
            ],
          ),
        ),
      );
    },
  );
}