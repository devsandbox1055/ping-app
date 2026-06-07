import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';

void main() async {
  // CRITICAL: Initialize Flutter bindings first
  WidgetsFlutterBinding.ensureInitialized();

  //  Check session on app startup
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final userId = prefs.getString('user_id');
  final pcCode = prefs.getString('pc_code');

  print("═══════════════════════════════════════════");
  print("🔍 Session Restore on App Start:");
  print("   is_logged_in: $isLoggedIn");
  print("   user_id:      $userId");
  print("   pc_code:      $pcCode");
  print("═══════════════════════════════════════════\n");

  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId, pcCode: pcCode));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;
  final String? pcCode;

  const MyApp({super.key, required this.isLoggedIn, this.userId, this.pcCode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couple Connect',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //Pass session data to SplashScreen
      home: SplashScreen(
        isLoggedIn: isLoggedIn,
        userId: userId,
        pcCode: pcCode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
