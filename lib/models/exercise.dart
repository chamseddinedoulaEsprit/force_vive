class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> muscleGroups;
  final String equipment;
  final String difficulty; // beginner, intermediate, advanced
  final String instructions;
  final String imageUrl;
  final bool isCompound; // exercice composé ou isolation
  final int estimatedDurationSeconds;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.imageUrl,
    required this.isCompound,
    required this.estimatedDurationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'muscleGroups': muscleGroups,
    'equipment': equipment,
    'difficulty': difficulty,
    'instructions': instructions,
    'imageUrl': imageUrl,
    'isCompound': isCompound,
    'estimatedDurationSeconds': estimatedDurationSeconds,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
    equipment: json['equipment'] ?? 'bodyweight',
    difficulty: json['difficulty'] ?? 'beginner',
    instructions: json['instructions'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    isCompound: json['isCompound'] ?? false,
    estimatedDurationSeconds: json['estimatedDurationSeconds'] ?? 60,
  );
}

class ExerciseSet {
  final int reps;
  final double weight; // kg
  final int durationSeconds;
  final int restSeconds;

  ExerciseSet({
    required this.reps,
    required this.weight,
    required this.durationSeconds,
    required this.restSeconds,
  });

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    'durationSeconds': durationSeconds,
    'restSeconds': restSeconds,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    reps: json['reps'] ?? 10,
    weight: json['weight']?.toDouble() ?? 0.0,
    durationSeconds: json['durationSeconds'] ?? 0,
    restSeconds: json['restSeconds'] ?? 60,
  );
}