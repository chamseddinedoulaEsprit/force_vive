class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String category; // workout, strength, consistency, milestone
  final int targetValue;
  final String unit; // sessions, kg, days, etc.
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.category,
    required this.targetValue,
    required this.unit,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconName': iconName,
    'category': category,
    'targetValue': targetValue,
    'unit': unit,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    iconName: json['iconName'] ?? 'star',
    category: json['category'] ?? 'milestone',
    targetValue: json['targetValue'] ?? 1,
    unit: json['unit'] ?? 'sessions',
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
  );
}

class UserStats {
  final int totalWorkouts;
  final int totalSets;
  final double totalVolumeLifted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkout;
  final Map<String, double> muscleGroupVolume;

  UserStats({
    this.totalWorkouts = 0,
    this.totalSets = 0,
    this.totalVolumeLifted = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkout,
    this.muscleGroupVolume = const {},
  });

  Map<String, dynamic> toJson() => {
    'totalWorkouts': totalWorkouts,
    'totalSets': totalSets,
    'totalVolumeLifted': totalVolumeLifted,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastWorkout': lastWorkout?.toIso8601String(),
    'muscleGroupVolume': muscleGroupVolume,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalWorkouts: json['totalWorkouts'] ?? 0,
    totalSets: json['totalSets'] ?? 0,
    totalVolumeLifted: json['totalVolumeLifted']?.toDouble() ?? 0.0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lastWorkout: json['lastWorkout'] != null ? DateTime.parse(json['lastWorkout']) : null,
    muscleGroupVolume: Map<String, double>.from(json['muscleGroupVolume'] ?? {}),
  );
}