import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String userIdKey = "user_id";
  static const String partnerIdKey = "partner_id";
  static const String inviteCodeKey = "invite_code";

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userIdKey);
  }

  static Future<void> savePartnerId(String partnerId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(partnerIdKey, partnerId);
  }

  static Future<String?> getPartnerId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(partnerIdKey);
  }

  static Future<void> saveInviteCode(String code) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(inviteCodeKey, code);
  }

  static Future<String?> getInviteCode() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(inviteCodeKey);
  }

  static Future<bool> isPaired() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(partnerIdKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
