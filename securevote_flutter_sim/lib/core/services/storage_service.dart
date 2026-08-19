import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyKycCompleted = 'kyc_completed';
  static const String _keyVotes = 'user_votes';
  static const String _keyNotifications = 'notifications';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Authentication
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      await _prefs?.setString(_keyUser, jsonEncode(userData));
      await _prefs?.setBool(_keyIsLoggedIn, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getUser() {
    try {
      final String? userJson = _prefs?.getString(_keyUser);
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUser(Map<String, dynamic> userData) async {
    return await saveUser(userData);
  }

  static bool isLoggedIn() {
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    await _prefs?.setBool(_keyIsLoggedIn, false);
    // Don't clear user data, just mark as logged out
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Onboarding Status
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  // KYC Status
  static Future<void> setKycCompleted(bool completed) async {
    await _prefs?.setBool(_keyKycCompleted, completed);
  }

  static bool isKycCompleted() {
    return _prefs?.getBool(_keyKycCompleted) ?? false;
  }

  // Votes Management
  static Future<void> saveVote(Map<String, dynamic> vote) async {
    try {
      final List<String> votes = _prefs?.getStringList(_keyVotes) ?? [];
      votes.add(jsonEncode(vote));
      await _prefs?.setStringList(_keyVotes, votes);
    } catch (e) {
      // Handle error
    }
  }

  static List<Map<String, dynamic>> getVotes() {
    try {
      final List<String>? votesJson = _prefs?.getStringList(_keyVotes);
      if (votesJson != null) {
        return votesJson
            .map((v) => jsonDecode(v) as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Check if user has voted in specific election
  static bool hasVotedInElection(String electionId) {
    final votes = getVotes();
    return votes.any((vote) => vote['electionId'] == electionId);
  }

  // Notifications
  static Future<void> saveNotification(
    Map<String, dynamic> notification,
  ) async {
    try {
      final List<String> notifications =
          _prefs?.getStringList(_keyNotifications) ?? [];
      notifications.insert(0, jsonEncode(notification)); // Add to beginning
      await _prefs?.setStringList(_keyNotifications, notifications);
    } catch (e) {
      // Handle error
    }
  }

  static List<Map<String, dynamic>> getNotifications() {
    try {
      final List<String>? notificationsJson = _prefs?.getStringList(
        _keyNotifications,
      );
      if (notificationsJson != null) {
        return notificationsJson
            .map((n) => jsonDecode(n) as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get user display name
  static String getUserDisplayName() {
    final user = getUser();
    if (user != null) {
      return user['fullName'] ?? user['email'] ?? 'User';
    }
    return 'User';
  }

  // Get user email
  static String getUserEmail() {
    final user = getUser();
    return user?['email'] ?? '';
  }

  // Get user phone
  static String getUserPhone() {
    final user = getUser();
    return user?['phone'] ?? '';
  }
}
