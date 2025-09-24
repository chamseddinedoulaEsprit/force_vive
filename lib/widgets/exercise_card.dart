import 'package:flutter/material.dart';
import 'package:force_vive/models/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
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
          child: Row(
            children: [
              // Image de l'exercice
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: exercise.imageUrl.isNotEmpty
                      ? Image.network(
                          exercise.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fitness_center,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            );
                          },
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Info de l'exercice
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et difficulté
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _DifficultyIndicator(difficulty: exercise.difficulty),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      exercise.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Métadonnées
                    Row(
                      children: [
                        // Équipement
                        Icon(
                          _getEquipmentIcon(exercise.equipment),
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getEquipmentName(exercise.equipment),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Temps estimé
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.estimatedDurationSeconds}s',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),

                        // Composé ou isolation
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: exercise.isCompound
                                ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5)
                                : Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exercise.isCompound ? 'Composé' : 'Isolation',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: exercise.isCompound
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment) {
      case 'bodyweight':
        return Icons.accessibility_new;
      case 'dumbbells':
        return Icons.fitness_center;
      case 'barbell':
        return Icons.straighten;
      case 'pull_up_bar':
        return Icons.horizontal_rule;
      default:
        return Icons.category;
    }
  }

  String _getEquipmentName(String equipment) {
    const equipmentNames = {
      'bodyweight': 'Poids du corps',
      'dumbbells': 'Haltères',
      'barbell': 'Barre',
      'pull_up_bar': 'Barre de traction',
    };
    return equipmentNames[equipment] ?? equipment;
  }
}

class _DifficultyIndicator extends StatelessWidget {
  final String difficulty;

  const _DifficultyIndicator({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    int level;

    switch (difficulty) {
      case 'beginner':
        color = Colors.green;
        level = 1;
        break;
      case 'intermediate':
        color = Colors.orange;
        level = 2;
        break;
      case 'advanced':
        color = Colors.red;
        level = 3;
        break;
      default:
        color = Colors.grey;
        level = 1;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.only(left: index > 0 ? 2 : 0),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: index < level ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}