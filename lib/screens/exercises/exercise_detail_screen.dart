import 'package:flutter/material.dart';
import 'package:force_vive/models/exercise.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Ajouter aux favoris
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté aux favoris')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image et difficulté
            Container(
              height: 250,
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Stack(
                children: [
                  // Image
                  if (widget.exercise.imageUrl.isNotEmpty)
                    Image.network(
                      widget.exercise.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                  // Overlay avec badge de difficulté
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _DifficultyBadge(difficulty: widget.exercise.difficulty),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et description
                  Text(
                    widget.exercise.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Informations techniques
                  _InfoSection(
                    title: 'Informations',
                    children: [
                      _InfoRow(
                        icon: Icons.category,
                        label: 'Équipement',
                        value: _getEquipmentName(widget.exercise.equipment),
                      ),
                      _InfoRow(
                        icon: Icons.schedule,
                        label: 'Durée estimée',
                        value: '${widget.exercise.estimatedDurationSeconds} secondes',
                      ),
                      _InfoRow(
                        icon: Icons.sports_gymnastics,
                        label: 'Type',
                        value: widget.exercise.isCompound ? 'Exercice composé' : 'Exercice d\'isolation',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Groupes musculaires
                  _InfoSection(
                    title: 'Groupes musculaires ciblés',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.exercise.muscleGroups.map((muscle) =>
                          Chip(
                            label: Text(_getMuscleGroupName(muscle)),
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            side: BorderSide.none,
                          )
                        ).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  _InfoSection(
                    title: 'Instructions d\'exécution',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          widget.exercise.instructions,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Conseils de sécurité
                  _InfoSection(
                    title: 'Conseils de sécurité',
                    children: [
                      _SafetyTip(
                        icon: Icons.warning_amber,
                        text: 'Échauffez-vous toujours avant de commencer l\'exercice',
                      ),
                      _SafetyTip(
                        icon: Icons.self_improvement,
                        text: 'Concentrez-vous sur une bonne forme plutôt que sur le poids',
                      ),
                      _SafetyTip(
                        icon: Icons.air,
                        text: 'Respirez correctement : expirez pendant l\'effort',
                      ),
                      _SafetyTip(
                        icon: Icons.stop_circle,
                        text: 'Arrêtez-vous si vous ressentez une douleur',
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Bouton d'ajout à un workout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Ajouter à un workout
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exercice ajouté à votre workout')),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter à un workout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEquipmentName(String equipment) {
    const equipmentNames = {
      'bodyweight': 'Poids du corps',
      'dumbbells': 'Haltères',
      'barbell': 'Barre et poids',
      'pull_up_bar': 'Barre de traction',
    };
    return equipmentNames[equipment] ?? equipment;
  }

  String _getMuscleGroupName(String muscle) {
    const muscleNames = {
      'chest': 'Pectoraux',
      'back': 'Dos',
      'shoulders': 'Épaules',
      'arms': 'Bras',
      'triceps': 'Triceps',
      'biceps': 'Biceps',
      'legs': 'Jambes',
      'glutes': 'Fessiers',
      'core': 'Abdominaux',
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SafetyTip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}