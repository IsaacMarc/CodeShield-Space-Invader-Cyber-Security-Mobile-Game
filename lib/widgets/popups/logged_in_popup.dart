import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/widgets/popups/signout_popup.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/core/app_text_styles.dart';

void showLoggedInPopup(BuildContext context, String username, int highscore, String email, String birthday) {
  final screenWidth = MediaQuery.of(context).size.width;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: screenWidth * 0.4, // Slightly wider to accommodate long emails
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Image.asset(
                  AppIcons.close,
                  width: 40,
                  filterQuality: FilterQuality.none,
                ),
                  ),
                  Text("LOGGED IN", style: TextStyle(color: Colors.white,fontSize: 26, fontFamily: 'PixelifySans' ,fontWeight: FontWeight.bold,) ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showSignOutPopup(context);
                    },
                    icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Stats
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: AppTextStyles.buttonLabel.copyWith(color: Colors.yellow, fontSize: 22)),
                    const SizedBox(height: 12),
                    Text("EMAIL: $email", style: AppTextStyles.bodyText.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text("BIRTH-DATE: $birthday", style: AppTextStyles.bodyText.copyWith(fontSize: 14)),
                    const SizedBox(height: 16),
                    Text("HIGHSCORE: ${highscore.toString().padLeft(9, '0')}", 
                      style: AppTextStyles.buttonLabel.copyWith(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}