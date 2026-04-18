import 'package:codeshield/Gameplay/difficulty_selection.dart';
import 'package:codeshield/screens/about_us_menu.dart';
import 'package:codeshield/screens/enemy_description/carousel_menu.dart';
import 'package:codeshield/screens/how_to_play/carousel_menu.dart';
import 'package:codeshield/widgets/popups/logged_in_popup.dart';
import 'package:flutter/material.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_text_styles.dart';
import 'package:codeshield/widgets/popups/logged_out_popup.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flame_audio/flame_audio.dart'; // Ensure this is imported

class MainMenu extends StatefulWidget {
  final String loggedInUser;
  const MainMenu({super.key, required this.loggedInUser});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late String username;
  late int highscore;

  static bool _isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    username = widget.loggedInUser;
    _refreshUserData();
    _startMenuMusic();
  }

  static int _trackToggle = 0;

void _startMenuMusic() {
  if (!_isMusicPlaying) {
    String track = _trackToggle == 0 ? 'mainmenumusic1.mp3' : 'mainmenumusic2.mp3';
    FlameAudio.bgm.play(track, volume: 0.4);
    
    _trackToggle = (_trackToggle + 1) % 2; // Flip between 0 and 1 for next time
    _isMusicPlaying = true;
  }
}

  void _stopMenuMusic() {
    FlameAudio.bgm.stop();
    _isMusicPlaying = false;
  }

 

  void _refreshUserData() {
    var userData = Hive.box('userBox').get(username);
    setState(() {
      highscore = userData != null ? (userData['highscore'] ?? 0) : 0;
    });
  }

  Route _createCyberRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive width check
    double screenWidth = MediaQuery.of(context).size.width;

    // Menu Buttons: Standardized size for mobile touch
    Widget colMenuButtons = Column(
      children: [
        _menuButton("PLAY", () => Navigator.of(context).push(_createCyberRoute(DifficultySelectionScreen(loggedInUser: username)))),
        _menuButton("HOW TO PLAY", () => Navigator.of(context).push(_createCyberRoute(const HowToPlayMenu()))),
        _menuButton("ENEMIES", () => Navigator.of(context).push(_createCyberRoute(const EnemyCarousel()))), // Shortened name for mobile
        _menuButton("ABOUT", () => Navigator.of(context).push(_createCyberRoute(const AboutUsMenu()))),
      ],
    );

    // Stats: Now centered and cleaner for portrait view
      Widget statsBox = Center( // Wrap in Center to ensure the box itself doesn't stretch
        child: Container(
          width: screenWidth * 0.3, // Shortens the box to 60% of the screen width
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7), // Slightly darker for better contrast
            border: Border.all(color: Colors.white, width: 1), // Solid retro white border
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Crucial: makes the box hug the content height
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(username, style: AppTextStyles.buttonLabel.copyWith(fontSize: 16)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      if (username == "GUEST") {
                        showLoggedOutPopup(context);
                      } else {
                        var userData = Hive.box('userBox').get(username);
                        showLoggedInPopup(
                          context, 
                          username, 
                          highscore, 
                          userData['email'] ?? "N/A", 
                          userData['birthday'] ?? "N/A"
                        );
                      }
                    },
                    child: Image.asset(AppIcons.edit, width: 24), // Tighter icon
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "HIGHSCORE: ${highscore.toString().padLeft(6, '0')}", 
                style: AppTextStyles.buttonLabel.copyWith(
                  fontSize: 12, 
                  color: Colors.yellowAccent
                )
              ),
            ],
          ),
        ),
      );

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(AppImages.menuBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    // Logo takes up 80% of screen width max
                    const SizedBox(height: 0),
                    Image.asset(AppImages.logo, width: screenWidth * 0.5),
                    const SizedBox(height: 30),
                    colMenuButtons,
                    const SizedBox(height: 30),
                    statsBox,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to keep buttons consistent
Widget _menuButton(String text, VoidCallback onPressed) { // Use VoidCallback
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextButton(
      onPressed: () {
        if (text == "PLAY") {
          _stopMenuMusic();
        }
        onPressed(); // This calls the logic you passed from the build method
      },
      style: TextButton.styleFrom(minimumSize: const Size(200, 50)),
      child: Text(text, style: AppTextStyles.buttonLabel.copyWith(fontSize: 20)),
    ),
  );
}
}