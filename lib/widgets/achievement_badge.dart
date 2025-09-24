import 'package:flutter/material.dart';
import 'package:force_vive/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool showUnlockDate;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showUnlockDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: achievement.isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor(context),
                  _getCategoryColor(context).withValues(alpha: 0.7),
                ],
              )
            : null,
        color: achievement.isUnlocked 
            ? null 
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? Colors.transparent
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: _getCategoryColor(context).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? Colors.white.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              color: achievement.isUnlocked
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          
          // Nom
          Text(
            achievement.name,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BuildContext context) {
    switch (achievement.category) {
      case 'workout':
        return Theme.of(context).colorScheme.primary;
      case 'strength':
        return Theme.of(context).colorScheme.secondary;
      case 'consistency':
        return Theme.of(context).colorScheme.tertiary;
      case 'milestone':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _getIcon() {
    switch (achievement.iconName) {
      case 'star':
        return Icons.star;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.emoji_events;
    }
  }
}

class AchievementDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementDialog({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCategoryColor(context),
              _getCategoryColor(context).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation des confettis (simulée avec des icônes)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.star, color: Colors.yellow.withValues(alpha: 0.8), size: 16),
                Icon(Icons.celebration, color: Colors.orange.withValues(alpha: 0.8), size: 20),
                Icon(Icons.star, color: Colors.yellow.withValues(alpha: 0.8), size: 16),
              ],
            ),
            const SizedBox(height: 16),
            
            // Icône principale
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            
            // Titre
            Text(
              'Achievement Débloqué !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Nom de l'achievement
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Bouton fermer
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _getCategoryColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Génial !'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context) {
    switch (achievement.category) {
      case 'workout':
        return Theme.of(context).colorScheme.primary;
      case 'strength':
        return Theme.of(context).colorScheme.secondary;
      case 'consistency':
        return Theme.of(context).colorScheme.tertiary;
      case 'milestone':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _getIcon() {
    switch (achievement.iconName) {
      case 'star':
        return Icons.star;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.emoji_events;
    }
  }
}