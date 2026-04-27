import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _currentUserKey = 'current_user_id';
  static const String _usersKey = 'users';
  static const String _messagesKey = 'messages';
  static const String _matchesKey = 'matches';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  static Future<void> saveCurrentUserId(String? userId) async {
    final prefs = await _prefs;
    if (userId == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, userId);
    }
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_currentUserKey);
  }

  static Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    try {
      final prefs = await _prefs;
      final jsonString = jsonEncode(users);
      await prefs.setString(_usersKey, jsonString);
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString(_usersKey);
      if (jsonString == null) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading users: $e');
      return [];
    }
  }

  static Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
    try {
      final prefs = await _prefs;
      final jsonString = jsonEncode(messages);
      await prefs.setString(_messagesKey, jsonString);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString(_messagesKey);
      if (jsonString == null) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }

  static Future<void> saveMatches(List<Map<String, dynamic>> matches) async {
    try {
      final prefs = await _prefs;
      final jsonString = jsonEncode(matches);
      await prefs.setString(_matchesKey, jsonString);
    } catch (e) {
      debugPrint('Error saving matches: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString(_matchesKey);
      if (jsonString == null) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading matches: $e');
      return [];
    }
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
