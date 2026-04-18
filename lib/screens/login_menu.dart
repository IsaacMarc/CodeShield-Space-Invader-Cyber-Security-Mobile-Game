import 'package:codeshield/screens/main_menu.dart';
import 'package:codeshield/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_text_styles.dart';
import 'package:codeshield/widgets/game_app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isPasswordVisible = false;
  final _userBox = Hive.box('userBox');

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _login() {
    String username = _userController.text.trim();
    String password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("Fields cannot be empty");
      return;
    }

    if (_userBox.containsKey(username)) {
      var userData = _userBox.get(username);
      if (userData['password'] == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenu(loggedInUser: username)),
        );
      } else {
        _showError("Invalid password");
      }
    } else {
      _showError("User not found");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic width for the Tecno Camon screen
    double screenWidth = MediaQuery.of(context).size.width;

    Widget dialogContents = Container(
      width: screenWidth * 0.6, // 90% of screen width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: SingleChildScrollView( // Prevents bottom overflow when keyboard is up
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("LOGIN", style: AppTextStyles.titleText.copyWith(fontSize: 32)),
            const SizedBox(height: 20),

            _buildPixelTextField(label: "USERNAME:", controller: _userController),
            const SizedBox(height: 10),

            _buildPixelTextField(
              label: "PASSWORD:", 
              controller: _passController, 
              isPassword: true
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainMenu(loggedInUser: "GUEST")),
                          );
                        },
                        child: Text(
                          "GUEST", // Shortened for small screens
                          style: AppTextStyles.buttonLabel.copyWith(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      const Text("|", style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          "REGISTER",
                          style: AppTextStyles.buttonLabel.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _login,
                  child: Text(
                    "CONFIRM",
                    style: AppTextStyles.buttonLabel.copyWith(
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MenuAppBar(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(AppImages.menuBackgroundAlt, fit: BoxFit.cover),
          ),
          SafeArea(child: Center(child: dialogContents)),
        ],
      ),
    );
  }

  Widget _buildPixelTextField({
    required String label, 
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Row(
      children: [
        // Using flex instead of fixed width for labels
        Expanded(
          flex: 3, 
          child: Text(label, style: AppTextStyles.bodyText.copyWith(fontSize: 14)),
        ),
        Expanded(
          flex: 7,
          child: TextField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            style: AppTextStyles.bodyText.copyWith(fontSize: 14),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black,
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ) 
                : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}