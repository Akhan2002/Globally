import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:globally/auth/auth.dart';
import 'package:globally/auth/login_or_register.dart';
import 'package:globally/firebase_options.dart';
import 'package:globally/pages/home_page.dart';
import 'package:globally/pages/profile_page.dart';
import 'package:globally/pages/users_page.dart';
import 'package:globally/theme/light_mode.dart';
import 'package:globally/theme/dark_mode.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/login_register_page':(context) => const LoginOrRegister(),
        '/home_page':(context) => HomePage(),
        '/profile_page':(context) => ProfilePage(),
        '/users_page':(context) => const UsersPage()
      },
    );
  }
}
