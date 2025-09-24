import 'package:force_vive/models/workout.dart';

class WorkoutSessionExercise {
  final String exerciseId;
  final String exerciseName;
  final List<CompletedSet> completedSets;

  WorkoutSessionExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.completedSets,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'completedSets': completedSets.map((s) => s.toJson()).toList(),
  };

  factory WorkoutSessionExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutSessionExercise(
        exerciseId: json['exerciseId'] ?? '',
        exerciseName: json['exerciseName'] ?? '',
        completedSets: (json['completedSets'] as List<dynamic>? ?? [])
            .map((s) => CompletedSet.fromJson(s))
            .toList(),
      );
}

class CompletedSet {
  final int reps;
  final double weight;
  final int durationSeconds;
  final DateTime completedAt;

  CompletedSet({
    required this.reps,
    required this.weight,
    required this.durationSeconds,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    'durationSeconds': durationSeconds,
    'completedAt': completedAt.toIso8601String(),
  };

  factory CompletedSet.fromJson(Map<String, dynamic> json) => CompletedSet(
    reps: json['reps'] ?? 0,
    weight: json['weight']?.toDouble() ?? 0.0,
    durationSeconds: json['durationSeconds'] ?? 0,
    completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
  );
}

class WorkoutSession {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WorkoutSessionExercise> exercises;
  final String notes;
  final bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startTime,
    this.endTime,
    required this.exercises,
    this.notes = '',
    this.isCompleted = false,
  });

  Duration? get duration => endTime != null ? endTime!.difference(startTime) : null;

  int get totalSets => exercises.fold(0, (sum, exercise) => sum + exercise.completedSets.length);

  double get totalVolume => exercises.fold(0.0, (sum, exercise) =>
      sum + exercise.completedSets.fold(0.0, (setSum, set) =>
          setSum + (set.weight * set.reps)));

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'workoutName': workoutName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'notes': notes,
    'isCompleted': isCompleted,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'] ?? '',
    workoutId: json['workoutId'] ?? '',
    workoutName: json['workoutName'] ?? '',
    startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    exercises: (json['exercises'] as List<dynamic>? ?? [])
        .map((e) => WorkoutSessionExercise.fromJson(e))
        .toList(),
    notes: json['notes'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
  );
}