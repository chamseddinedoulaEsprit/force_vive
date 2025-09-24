import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/models/workout_session.dart';
import 'package:force_vive/models/achievement.dart';

class LocalStorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _workoutSessionsKey = 'workout_sessions';
  static const String _userStatsKey = 'user_stats';
  static const String _achievementsKey = 'achievements';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    await init();
    await _prefs!.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> getUserProfile() async {
    await init();
    final profileJson = _prefs!.getString(_userProfileKey);
    if (profileJson == null) return null;
    return UserProfile.fromJson(jsonDecode(profileJson));
  }

  // Workout Sessions
  static Future<void> saveWorkoutSession(WorkoutSession session) async {
    await init();
    final sessions = await getWorkoutSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
    await _saveWorkoutSessions(sessions);
  }

  static Future<List<WorkoutSession>> getWorkoutSessions() async {
    await init();
    final sessionsJson = _prefs!.getString(_workoutSessionsKey);
    if (sessionsJson == null) return [];
    
    final List<dynamic> sessionsList = jsonDecode(sessionsJson);
    return sessionsList.map((s) => WorkoutSession.fromJson(s)).toList();
  }

  static Future<void> _saveWorkoutSessions(List<WorkoutSession> sessions) async {
    await init();
    final sessionsJson = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs!.setString(_workoutSessionsKey, sessionsJson);
  }

  // User Stats
  static Future<void> saveUserStats(UserStats stats) async {
    await init();
    await _prefs!.setString(_userStatsKey, jsonEncode(stats.toJson()));
  }

  static Future<UserStats> getUserStats() async {
    await init();
    final statsJson = _prefs!.getString(_userStatsKey);
    if (statsJson == null) return UserStats();
    return UserStats.fromJson(jsonDecode(statsJson));
  }

  // Achievements
  static Future<void> saveAchievements(List<Achievement> achievements) async {
    await init();
    final achievementsJson = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await _prefs!.setString(_achievementsKey, achievementsJson);
  }

  static Future<List<Achievement>> getAchievements() async {
    await init();
    final achievementsJson = _prefs!.getString(_achievementsKey);
    if (achievementsJson == null) return [];
    
    final List<dynamic> achievementsList = jsonDecode(achievementsJson);
    return achievementsList.map((a) => Achievement.fromJson(a)).toList();
  }

  // Onboarding
  static Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await _prefs!.setBool(_onboardingCompletedKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    await init();
    return _prefs!.getBool(_onboardingCompletedKey) ?? false;
  }

  // Utility methods
  static Future<void> clearAllData() async {
    await init();
    await _prefs!.clear();
  }

  static Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final sessions = await getWorkoutSessions();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.take(limit).toList();
  }

  static Future<List<WorkoutSession>> getSessionsInDateRange(DateTime start, DateTime end) async {
    final sessions = await getWorkoutSessions();
    return sessions.where((session) =>
        session.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
        session.startTime.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }
}