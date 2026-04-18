import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:codeshield/core/app_assets.dart';
import 'package:codeshield/core/app_text_styles.dart';
import 'package:codeshield/widgets/game_app_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isPasswordVisible = false;
  final _userBox = Hive.box('userBox');

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _birthController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  bool _validateInputs() {
    String username = _userController.text.trim();
    String email = _emailController.text.trim();
    String birthday = _birthController.text.trim();
    String password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty || email.isEmpty || birthday.isEmpty) {
      _showError("All fields are required.");
      return false;
    }

    if (username.length > 12) {
      _showError("Username is too long (Max 12).");
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError("Invalid email format (e.g. user@mail.com)");
      return false;
    }

    try {
      DateTime.parse(birthday);
    } catch (e) {
      _showError("Invalid date. Use YYYY-MM-DD (e.g. 2000-01-01)");
      return false;
    }

    return true;
  }

  void _registerUser() {
    if (!_validateInputs()) return;

    String username = _userController.text.trim();
    String password = _passController.text.trim();
    String email = _emailController.text.trim();
    String birthday = _birthController.text.trim();

    if (_userBox.containsKey(username)) {
      _showError("Username already taken!");
      return;
    }

    _userBox.put(username, {
      'password': password,
      'email': email,
      'birthday': birthday,
      'highscore': 0,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic width for the 1080x2436 Tecno screen
    double screenWidth = MediaQuery.of(context).size.width;

    Widget dialogContents = Container(
      width: screenWidth * 0.6, // Responsive 90% width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: SingleChildScrollView( // Essential for when the keyboard pops up
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("REGISTER", style: AppTextStyles.titleText.copyWith(fontSize: 32)),
            const SizedBox(height: 30),

            _buildPixelTextField(
              label: "USERNAME:", 
              controller: _userController,
              maxLength: 12,
            ),
            const SizedBox(height: 15),

            _buildPixelTextField(label: "EMAIL:", controller: _emailController),
            const SizedBox(height: 15),

            _buildPixelTextField(label: "BIRTHDAY:", controller: _birthController),
            const SizedBox(height: 15),

            _buildPixelTextField(
              label: "PASSWORD:", 
              controller: _passController, 
              isPassword: true
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _registerUser,
                child: Text(
                  "CONFIRM",
                  style: AppTextStyles.buttonLabel.copyWith(
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
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
    int? maxLength,
  }) {
    return Row(
      children: [
        // Responsive label width (30% of the row)
        Expanded(
          flex: 3, 
          child: Text(label, style: AppTextStyles.bodyText.copyWith(fontSize: 14)),
        ),
        // Responsive input width (70% of the row)
        Expanded(
          flex: 7,
          child: TextField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            maxLength: maxLength,
            style: AppTextStyles.bodyText.copyWith(fontSize: 14),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              counterText: "",
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