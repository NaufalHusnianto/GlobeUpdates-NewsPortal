import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:globeupdates/pages/home_screen.dart';
import 'package:globeupdates/theme/theme.dart';
import 'package:globeupdates/auth.dart';
import 'package:globeupdates/pages/login_register_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
