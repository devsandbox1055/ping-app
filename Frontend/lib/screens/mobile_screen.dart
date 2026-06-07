import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'gf_status_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      if (_isMounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter a code')));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://"backend url/api/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code}),
      );

      final data = json.decode(response.body);

      if (data['valid']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', code);
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('login_role', 'mobile');
        await prefs.setString('connected_to', code);

        print("✅ Session Saved (Mobile User):");
        print("   user_id:       $code");
        print("   is_logged_in:  true");
        print("   login_role:    mobile");
        print("   connected_to:  $code");

        if (_isMounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GFStatusScreen(boyfriendUserId: code),
            ),
          );
        }
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Authentication failed: $e')));
      }
    } finally {
      if (_isMounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to PC'),
        backgroundColor: const Color.fromARGB(218, 243, 172, 255),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android, size: 100, color: Colors.purple),
              const SizedBox(height: 30),
              const Text(
                'Enter PC Code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ask your partner for the code',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'XXXXXXXX',
                  hintStyle: const TextStyle(fontSize: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Authenticate',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
