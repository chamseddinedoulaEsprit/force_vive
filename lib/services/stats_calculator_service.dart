import 'package:force_vive/models/workout_session.dart';
import 'package:force_vive/models/achievement.dart';

class StatsCalculatorService {
  static UserStats calculateUserStats(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return UserStats();

    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    completedSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    final totalWorkouts = completedSessions.length;
    final totalSets = completedSessions.fold(0, (sum, session) => sum + session.totalSets);
    final totalVolumeLifted = completedSessions.fold(0.0, (sum, session) => sum + session.totalVolume);
    
    final streaks = _calculateStreaks(completedSessions);
    final muscleGroupVolume = _calculateMuscleGroupVolume(completedSessions);

    return UserStats(
      totalWorkouts: totalWorkouts,
      totalSets: totalSets,
      totalVolumeLifted: totalVolumeLifted,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      lastWorkout: completedSessions.isNotEmpty ? completedSessions.last.startTime : null,
      muscleGroupVolume: muscleGroupVolume,
    );
  }

  static Map<String, int> _calculateStreaks(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return {'current': 0, 'longest': 0};

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    DateTime? lastWorkoutDate;
    final now = DateTime.now();

    // Trier par date décroissante pour calculer le streak actuel
    final sortedSessions = List<WorkoutSession>.from(sessions);
    sortedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    // Calculer le streak actuel
    for (final session in sortedSessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      final today = DateTime(now.year, now.month, now.day);
      
      if (lastWorkoutDate == null) {
        if (sessionDate.difference(today).inDays.abs() <= 1) {
          currentStreak = 1;
          lastWorkoutDate = sessionDate;
        } else {
          break;
        }
      } else {
        final daysDiff = lastWorkoutDate.difference(sessionDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
          lastWorkoutDate = sessionDate;
        } else if (daysDiff == 0) {
          // Même jour, ne pas incrémenter
          continue;
        } else {
          break;
        }
      }
    }

    // Calculer le streak le plus long
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    DateTime? previousDate;
    
    for (final session in sessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      
      if (previousDate == null) {
        tempStreak = 1;
      } else {
        final daysDiff = sessionDate.difference(previousDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else if (daysDiff > 1) {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
        // Si daysDiff == 0 (même jour), on ne change rien
      }
      
      previousDate = sessionDate;
    }
    
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  static Map<String, double> _calculateMuscleGroupVolume(List<WorkoutSession> sessions) {
    final muscleGroupVolume = <String, double>{};
    
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final volume = exercise.completedSets.fold(0.0, 
          (sum, set) => sum + (set.weight * set.reps));
        
        // Pour simplifier, on assigne le volume à tous les groupes musculaires de l'exercice
        // Dans une vraie app, on aurait les groupes musculaires stockés avec chaque exercice
        final muscleGroup = exercise.exerciseName.toLowerCase().contains('chest') ? 'chest' :
                           exercise.exerciseName.toLowerCase().contains('back') ? 'back' :
                           exercise.exerciseName.toLowerCase().contains('leg') ? 'legs' :
                           exercise.exerciseName.toLowerCase().contains('shoulder') ? 'shoulders' :
                           'other';
        
        muscleGroupVolume[muscleGroup] = (muscleGroupVolume[muscleGroup] ?? 0) + volume;
      }
    }
    
    return muscleGroupVolume;
  }

  static List<Achievement> checkAchievements(UserStats stats, List<Achievement> allAchievements) {
    final newlyUnlocked = <Achievement>[];
    
    for (final achievement in allAchievements.where((a) => !a.isUnlocked)) {
      bool shouldUnlock = false;
      
      switch (achievement.category) {
        case 'workout':
          shouldUnlock = stats.totalWorkouts >= achievement.targetValue;
          break;
        case 'strength':
          shouldUnlock = stats.totalVolumeLifted >= achievement.targetValue;
          break;
        case 'consistency':
          shouldUnlock = stats.currentStreak >= achievement.targetValue ||
                        stats.longestStreak >= achievement.targetValue;
          break;
        case 'milestone':
          shouldUnlock = stats.totalSets >= achievement.targetValue;
          break;
      }
      
      if (shouldUnlock) {
        newlyUnlocked.add(Achievement(
          id: achievement.id,
          name: achievement.name,
          description: achievement.description,
          iconName: achievement.iconName,
          category: achievement.category,
          targetValue: achievement.targetValue,
          unit: achievement.unit,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }
    
    return newlyUnlocked;
  }

  static Map<String, double> getWeeklyProgress(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyProgress = <String, double>{};
    
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayName = _getDayName(day.weekday);
      
      final dayVolume = sessions
          .where((s) => _isSameDay(s.startTime, day))
          .fold(0.0, (sum, session) => sum + session.totalVolume);
      
      weeklyProgress[dayName] = dayVolume;
    }
    
    return weeklyProgress;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  static String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }
}