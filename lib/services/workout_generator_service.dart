import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/models/workout.dart';
import 'package:force_vive/models/exercise.dart';
import 'package:force_vive/utils/sample_data.dart';

class WorkoutGeneratorService {
  static List<Workout> generateWorkoutPlan(UserProfile profile) {
    final availableExercises = SampleData.exercises
        .where((exercise) => 
            profile.availableEquipment.contains(exercise.equipment) ||
            exercise.equipment == 'bodyweight')
        .toList();

    final workouts = <Workout>[];
    
    // Générer des workouts basés sur le niveau et les objectifs
    if (profile.goals.contains('muscle_gain')) {
      workouts.addAll(_generateStrengthWorkouts(availableExercises, profile));
    }
    
    if (profile.goals.contains('weight_loss')) {
      workouts.addAll(_generateCardioWorkouts(availableExercises, profile));
    }
    
    if (profile.goals.contains('strength')) {
      workouts.addAll(_generatePowerWorkouts(availableExercises, profile));
    }

    return workouts;
  }

  static List<Workout> _generateStrengthWorkouts(List<Exercise> exercises, UserProfile profile) {
    final workouts = <Workout>[];
    
    // Workout Haut du corps
    final upperBodyExercises = exercises
        .where((e) => ['chest', 'back', 'shoulders', 'arms'].any((muscle) => 
            e.muscleGroups.contains(muscle)))
        .take(6)
        .toList();
    
    if (upperBodyExercises.isNotEmpty) {
      workouts.add(_createWorkout(
        'upper_body_strength',
        'Force Haut du Corps',
        'Développez la force de votre buste',
        upperBodyExercises,
        profile.fitnessLevel,
        'strength'
      ));
    }

    // Workout Bas du corps  
    final lowerBodyExercises = exercises
        .where((e) => ['legs', 'glutes'].any((muscle) => 
            e.muscleGroups.contains(muscle)))
        .take(5)
        .toList();
    
    if (lowerBodyExercises.isNotEmpty) {
      workouts.add(_createWorkout(
        'lower_body_strength',
        'Force Bas du Corps',
        'Renforcez vos jambes et fessiers',
        lowerBodyExercises,
        profile.fitnessLevel,
        'strength'
      ));
    }

    return workouts;
  }

  static List<Workout> _generateCardioWorkouts(List<Exercise> exercises, UserProfile profile) {
    final cardioExercises = exercises
        .where((e) => e.equipment == 'bodyweight')
        .take(8)
        .toList();

    if (cardioExercises.isEmpty) return [];

    return [_createWorkout(
      'hiit_cardio',
      'HIIT Cardio',
      'Brûlez les calories efficacement',
      cardioExercises,
      profile.fitnessLevel,
      'cardio'
    )];
  }

  static List<Workout> _generatePowerWorkouts(List<Exercise> exercises, UserProfile profile) {
    final compoundExercises = exercises
        .where((e) => e.isCompound)
        .take(5)
        .toList();

    if (compoundExercises.isEmpty) return [];

    return [_createWorkout(
      'power_compound',
      'Force Composée',
      'Exercices poly-articulaires pour la puissance',
      compoundExercises,
      profile.fitnessLevel,
      'strength'
    )];
  }

  static Workout _createWorkout(String id, String name, String description, 
      List<Exercise> exercises, String fitnessLevel, String category) {
    
    final workoutExercises = exercises.map((exercise) {
      final sets = _generateSetsForExercise(exercise, fitnessLevel, category);
      return WorkoutExercise(exercise: exercise, sets: sets);
    }).toList();

    final estimatedDuration = workoutExercises.fold(0, (total, we) =>
        total + we.sets.fold(0, (setTotal, set) =>
            setTotal + set.durationSeconds + set.restSeconds));

    final targetMuscles = exercises
        .expand((e) => e.muscleGroups)
        .toSet()
        .toList();

    return Workout(
      id: id,
      name: name,
      description: description,
      exercises: workoutExercises,
      difficulty: fitnessLevel,
      estimatedDurationMinutes: (estimatedDuration / 60).round(),
      targetMuscleGroups: targetMuscles,
      category: category,
    );
  }

  static List<ExerciseSet> _generateSetsForExercise(Exercise exercise, String fitnessLevel, String category) {
    int sets = 3;
    int reps = 12;
    int rest = 60;

    switch (fitnessLevel) {
      case 'beginner':
        sets = 2;
        reps = 10;
        rest = 90;
        break;
      case 'intermediate':
        sets = 3;
        reps = 12;
        rest = 60;
        break;
      case 'advanced':
        sets = 4;
        reps = 15;
        rest = 45;
        break;
    }

    if (category == 'cardio') {
      reps = 30; // 30 secondes d'effort
      rest = 15; // 15 secondes de repos
    }

    return List.generate(sets, (index) => ExerciseSet(
      reps: reps,
      weight: 0, // L'utilisateur ajustera
      durationSeconds: category == 'cardio' ? 30 : 0,
      restSeconds: rest,
    ));
  }

  static Workout? getRecommendedWorkout(UserProfile profile, List<String> recentWorkoutIds) {
    final availableWorkouts = generateWorkoutPlan(profile);
    
    // Éviter les workouts récents
    final unrecentWorkouts = availableWorkouts
        .where((w) => !recentWorkoutIds.contains(w.id))
        .toList();
    
    if (unrecentWorkouts.isEmpty) return availableWorkouts.isNotEmpty ? availableWorkouts.first : null;
    
    // Prioriser selon les objectifs
    if (profile.goals.contains('muscle_gain')) {
      final strengthWorkout = unrecentWorkouts.firstWhere(
        (w) => w.category == 'strength',
        orElse: () => unrecentWorkouts.first
      );
      return strengthWorkout;
    }
    
    return unrecentWorkouts.first;
  }
}