import 'package:force_vive/models/exercise.dart';

class WorkoutExercise {
  final Exercise exercise;
  final List<ExerciseSet> sets;
  final String notes;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'sets': sets.map((s) => s.toJson()).toList(),
    'notes': notes,
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    exercise: Exercise.fromJson(json['exercise'] ?? {}),
    sets: (json['sets'] as List<dynamic>? ?? [])
        .map((s) => ExerciseSet.fromJson(s))
        .toList(),
    notes: json['notes'] ?? '',
  );
}

class Workout {
  final String id;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final String difficulty;
  final int estimatedDurationMinutes;
  final List<String> targetMuscleGroups;
  final String category; // strength, cardio, flexibility, etc.

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.difficulty,
    required this.estimatedDurationMinutes,
    required this.targetMuscleGroups,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'difficulty': difficulty,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'targetMuscleGroups': targetMuscleGroups,
    'category': category,
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    exercises: (json['exercises'] as List<dynamic>? ?? [])
        .map((e) => WorkoutExercise.fromJson(e))
        .toList(),
    difficulty: json['difficulty'] ?? 'beginner',
    estimatedDurationMinutes: json['estimatedDurationMinutes'] ?? 30,
    targetMuscleGroups: List<String>.from(json['targetMuscleGroups'] ?? []),
    category: json['category'] ?? 'strength',
  );
}