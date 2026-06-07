import 'package:flutter/material.dart';
import 'mobile_screen.dart';
import 'gf_status_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String? userId;
  final String? pcCode;

  const SplashScreen({
    super.key,
    required this.isLoggedIn,
    this.userId,
    this.pcCode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (widget.isLoggedIn && widget.userId != null) {
      debugPrint("✅ User logged in! userId: ${widget.userId}");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GFStatusScreen(boyfriendUserId: widget.userId!),
          ),
        );
      }
    } else {
      debugPrint("⚪ No session. Showing code entry screen...");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MobileScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               
              _buildLogo(),
              const SizedBox(height: 20),
              const Text(
                '',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Stay connected with your partner',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Transform.translate(
      offset: const Offset(0, 80),
      child: Image.asset(
        'assets/images/logo2.png',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.favorite, size: 80, color: Colors.white);
        },
      ),
    );
  }
}
