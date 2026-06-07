import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/session.json');
  }

  static Future<void> saveSession(String userId) async {
    final file = await _getFile();
    final data = {
      'user_id': userId,
      'is_logged_in': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(json.encode(data));
    print("Session saved to file: $userId");
  }

  static Future<String?> getUserId() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents);
        return data['user_id'];
      }
    } catch (e) {
      print("Error reading session: $e");
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents);
        return data['is_logged_in'] ?? false;
      }
    } catch (e) {}
    return false;
  }

  static Future<void> clearSession() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
    print("Session cleared");
  }
}
