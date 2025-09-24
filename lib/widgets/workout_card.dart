import 'package:flutter/material.dart';
import 'package:force_vive/models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progressValue;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.showProgress = false,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icône de catégorie
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Info principale
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          workout.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Badge de difficulté
                  _DifficultyBadge(difficulty: workout.difficulty),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Métadonnées
              Row(
                children: [
                  _MetaItem(
                    icon: Icons.schedule,
                    text: '${workout.estimatedDurationMinutes}min',
                  ),
                  const SizedBox(width: 16),
                  _MetaItem(
                    icon: Icons.fitness_center,
                    text: '${workout.exercises.length} exercices',
                  ),
                  const SizedBox(width: 16),
                  _MetaItem(
                    icon: Icons.category,
                    text: workout.category,
                  ),
                ],
              ),
              
              // Groupes musculaires
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: workout.targetMuscleGroups.take(3).map((muscle) =>
                  Chip(
                    label: Text(
                      _getMuscleGroupName(muscle),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )
                ).toList(),
              ),
              
              // Barre de progression (si applicable)
              if (showProgress && progressValue != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progressValue! * 100).toInt()}% complété',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
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

  IconData _getCategoryIcon() {
    switch (workout.category) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      default:
        return Icons.category;
    }
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

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (difficulty) {
      case 'beginner':
        color = Colors.green;
        label = 'Débutant';
        break;
      case 'intermediate':
        color = Colors.orange;
        label = 'Intermédiaire';
        break;
      case 'advanced':
        color = Colors.red;
        label = 'Avancé';
        break;
      default:
        color = Colors.grey;
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}