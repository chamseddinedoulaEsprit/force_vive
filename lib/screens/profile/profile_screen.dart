import 'package:flutter/material.dart';
import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/models/achievement.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/widgets/achievement_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  UserStats _stats = UserStats();
  List<Achievement> _recentAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await LocalStorageService.getUserProfile();
    final stats = await LocalStorageService.getUserStats();
    final achievements = await LocalStorageService.getAchievements();
    final recentAchievements = achievements
        .where((a) => a.isUnlocked)
        .take(4)
        .toList();

    setState(() {
      _profile = profile;
      _stats = stats;
      _recentAchievements = recentAchievements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsBottomSheet(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // En-tête du profil
              _ProfileHeader(profile: _profile!, stats: _stats),
              const SizedBox(height: 24),

              // Informations personnelles
              _ProfileInfoSection(profile: _profile!),
              const SizedBox(height: 24),

              // Objectifs et préférences
              _GoalsSection(profile: _profile!),
              const SizedBox(height: 24),

              // Achievements récents
              if (_recentAchievements.isNotEmpty) ...[
                _AchievementsSection(achievements: _recentAchievements),
                const SizedBox(height: 24),
              ],

              // Statistiques rapides
              _QuickStatsSection(stats: _stats),
              const SizedBox(height: 24),

              // Actions rapides
              _QuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paramètres',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            _SettingsItem(
              icon: Icons.edit,
              title: 'Modifier le profil',
              subtitle: 'Mettre à jour vos informations',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                );
              },
            ),
            _SettingsItem(
              icon: Icons.notification_add,
              title: 'Notifications',
              subtitle: 'Rappels d\'entraînement',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                );
              },
            ),
            _SettingsItem(
              icon: Icons.backup,
              title: 'Sauvegarder les données',
              subtitle: 'Exporter vos progrès',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
                );
              },
            ),
            _SettingsItem(
              icon: Icons.delete_outline,
              title: 'Réinitialiser',
              subtitle: 'Effacer toutes les données',
              textColor: Theme.of(context).colorScheme.error,
              onTap: () => _showResetDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    Navigator.pop(context); // Fermer le bottom sheet
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les données'),
        content: const Text(
          'Cette action supprimera définitivement toutes vos données d\'entraînement, statistiques et achievements. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorageService.clearAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Données réinitialisées')),
                );
                // Recharger l'application ou naviguer vers onboarding
              }
            },
            child: Text(
              'Réinitialiser',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final UserStats stats;

  const _ProfileHeader({required this.profile, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nom et niveau
          Text(
            profile.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getLevelDisplayName(profile.fitnessLevel),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeaderStat(
                value: '${stats.totalWorkouts}',
                label: 'Séances',
              ),
              _HeaderStat(
                value: '${stats.currentStreak}',
                label: 'Streak',
              ),
              _HeaderStat(
                value: '${profile.bmi.toStringAsFixed(1)}',
                label: 'IMC',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLevelDisplayName(String level) {
    const levelNames = {
      'beginner': 'Débutant',
      'intermediate': 'Intermédiaire',
      'advanced': 'Avancé',
    };
    return levelNames[level] ?? level;
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

class _ProfileInfoSection extends StatelessWidget {
  final UserProfile profile;

  const _ProfileInfoSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Informations personnelles',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.cake,
            label: 'Âge',
            value: '${profile.age} ans',
          ),
          _InfoRow(
            icon: Icons.monitor_weight,
            label: 'Poids',
            value: '${profile.weight.toInt()}kg',
          ),
          _InfoRow(
            icon: Icons.height,
            label: 'Taille',
            value: '${profile.height.toInt()}cm',
          ),
          _InfoRow(
            icon: Icons.assessment,
            label: 'IMC',
            value: '${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})',
          ),
        ],
      ),
    );
  }
}

class _GoalsSection extends StatelessWidget {
  final UserProfile profile;

  const _GoalsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Objectifs et préférences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objectifs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: profile.goals.map((goal) => Chip(
              label: Text(_getGoalDisplayName(goal)),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Équipement disponible',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: profile.availableEquipment.map((equipment) => Chip(
              label: Text(_getEquipmentDisplayName(equipment)),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.schedule,
                  label: 'Fréquence',
                  value: '${profile.workoutDaysPerWeek} fois/semaine',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoRow(
                  icon: Icons.timer,
                  label: 'Durée',
                  value: '${profile.workoutDurationMinutes}min',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGoalDisplayName(String goal) {
    const goalNames = {
      'muscle_gain': 'Prise de masse',
      'weight_loss': 'Perte de poids',
      'strength': 'Force',
      'endurance': 'Endurance',
    };
    return goalNames[goal] ?? goal;
  }

  String _getEquipmentDisplayName(String equipment) {
    const equipmentNames = {
      'bodyweight': 'Poids du corps',
      'dumbbells': 'Haltères',
      'barbell': 'Barre et poids',
      'pull_up_bar': 'Barre de traction',
    };
    return equipmentNames[equipment] ?? equipment;
  }
}

class _AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Achievements récents',
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: index == achievements.length - 1 ? 0 : 12),
              child: AchievementBadge(achievement: achievements[index]),
            );
          },
        ),
      ),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  final UserStats stats;

  const _QuickStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Statistiques',
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.repeat,
              value: '${stats.totalSets}',
              label: 'Séries totales',
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatItem(
              icon: Icons.trending_up,
              value: '${stats.totalVolumeLifted.toInt()}kg',
              label: 'Volume soulevé',
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Actions rapides',
      child: Column(
        children: [
          _ActionItem(
            icon: Icons.share,
            title: 'Partager mes progrès',
            subtitle: 'Partagez vos achievements',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
              );
            },
          ),
          _ActionItem(
            icon: Icons.help_outline,
            title: 'Aide et support',
            subtitle: 'Besoin d\'aide ?',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
              );
            },
          ),
          _ActionItem(
            icon: Icons.info_outline,
            title: 'À propos',
            subtitle: 'Force Vive v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Force Vive',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Force Vive',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: textColor != null 
            ? Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor)
            : Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}