import 'package:codeshield/screens/enemy_description/enemy_details.dart';
import 'package:codeshield/screens/login_menu.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox'); // Ensure the box is open before the app starts

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // The app now starts here
      home: const LoginPage(), 
      routes: {
    '/enemy_details': (context) => const EnemyDetails(),
    // ... your other routes
  },
    ),
  );
}