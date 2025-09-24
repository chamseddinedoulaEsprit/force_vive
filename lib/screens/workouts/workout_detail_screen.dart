import 'package:flutter/material.dart';
import 'package:force_vive/models/workout.dart';
import 'package:force_vive/screens/workouts/active_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Partager le workout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Partage bientôt disponible')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Sauvegarder le workout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout sauvegardé')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête du workout
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(context),
                          _getCategoryColor(context).withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workout.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats du workout
                        Row(
                          children: [
                            _WorkoutStat(
                              icon: Icons.schedule,
                              value: '${workout.estimatedDurationMinutes}min',
                              label: 'Durée',
                            ),
                            const SizedBox(width: 24),
                            _WorkoutStat(
                              icon: Icons.fitness_center,
                              value: '${workout.exercises.length}',
                              label: 'Exercices',
                            ),
                            const SizedBox(width: 24),
                            _WorkoutStat(
                              icon: Icons.category,
                              value: _getCategoryName(workout.category),
                              label: 'Type',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Groupes musculaires ciblés
                        Text(
                          'Groupes musculaires ciblés',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: workout.targetMuscleGroups.map((muscle) =>
                            Chip(
                              label: Text(_getMuscleGroupName(muscle)),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                              side: BorderSide.none,
                            )
                          ).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Liste des exercices
                        Text(
                          'Exercices (${workout.exercises.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        ...workout.exercises.asMap().entries.map((entry) {
                          final index = entry.key;
                          final workoutExercise = entry.value;
                          return _ExerciseItem(
                            index: index + 1,
                            workoutExercise: workoutExercise,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton de démarrage
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ActiveWorkoutScreen(workout: workout),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Commencer l\'entraînement'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _getCategoryColor(context),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BuildContext context) {
    switch (workout.category) {
      case 'strength':
        return Theme.of(context).colorScheme.primary;
      case 'cardio':
        return Theme.of(context).colorScheme.secondary;
      case 'flexibility':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _getCategoryName(String category) {
    const categoryNames = {
      'strength': 'Force',
      'cardio': 'Cardio',
      'flexibility': 'Souplesse',
    };
    return categoryNames[category] ?? category;
  }

  String _getMuscleGroupName(String muscle) {
    const muscleNames = {
      'chest': 'Pectoraux',
      'back': 'Dos',
      'shoulders': 'Épaules',
      'arms': 'Bras',
      'legs': 'Jambes',
      'glutes': 'Fessiers',
      'core': 'Abdos',
      'full_body': 'Corps entier',
    };
    return muscleNames[muscle] ?? muscle;
  }
}

class _WorkoutStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WorkoutStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final int index;
  final WorkoutExercise workoutExercise;

  const _ExerciseItem({
    required this.index,
    required this.workoutExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Numéro
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info exercice
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutExercise.exercise.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workoutExercise.sets.length} séries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Détail des séries
                Wrap(
                  spacing: 8,
                  children: workoutExercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key + 1;
                    final set = entry.value;
                    return Chip(
                      label: Text(
                        set.durationSeconds > 0
                            ? 'S$setIndex: ${set.durationSeconds}s'
                            : 'S$setIndex: ${set.reps} reps',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      side: BorderSide.none,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}