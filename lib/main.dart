import 'package:flutter/material.dart';
import 'package:globally/theme/light_mode.dart';
import 'package:globally/theme/dark_mode.dart';
import 'package:globally/auth/login_or_register.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
