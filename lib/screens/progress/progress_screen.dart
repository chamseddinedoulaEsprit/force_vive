import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:force_vive/models/workout_session.dart';
import 'package:force_vive/models/achievement.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/services/stats_calculator_service.dart';
import 'package:force_vive/widgets/progress_chart.dart';
import 'package:force_vive/widgets/achievement_badge.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserStats _stats = UserStats();
  List<WorkoutSession> _sessions = [];
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final sessions = await LocalStorageService.getWorkoutSessions();
    final stats = StatsCalculatorService.calculateUserStats(sessions);
    final achievements = await LocalStorageService.getAchievements();

    setState(() {
      _sessions = sessions;
      _stats = stats;
      _achievements = achievements;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Progrès'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Statistiques', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Historique', icon: Icon(Icons.history)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StatsTab(stats: _stats, sessions: _sessions),
          _HistoryTab(sessions: _sessions),
          _AchievementsTab(achievements: _achievements),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final UserStats stats;
  final List<WorkoutSession> sessions;

  const _StatsTab({required this.stats, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final weeklyProgress = StatsCalculatorService.getWeeklyProgress(sessions);
    
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Recharger les données
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vue d'ensemble
            _OverviewCards(stats: stats),
            const SizedBox(height: 24),

            // Graphique de progression hebdomadaire
            Text(
              'Progression cette semaine',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ProgressChart(weeklyData: weeklyProgress),
            ),
            const SizedBox(height: 24),

            // Répartition par groupes musculaires
            if (stats.muscleGroupVolume.isNotEmpty) ...[
              Text(
                'Volume par groupe musculaire',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _MuscleGroupChart(muscleGroupVolume: stats.muscleGroupVolume),
              const SizedBox(height: 24),
            ],

            // Records personnels
            Text(
              'Mes records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _PersonalRecords(sessions: sessions),
          ],
        ),
      ),
    );
  }
}

class _OverviewCards extends StatelessWidget {
  final UserStats stats;

  const _OverviewCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.fitness_center,
                title: 'Total Séances',
                value: '${stats.totalWorkouts}',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                title: 'Streak Actuel',
                value: '${stats.currentStreak} jours',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                title: 'Volume Total',
                value: '${stats.totalVolumeLifted.toInt()}kg',
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.star,
                title: 'Record Streak',
                value: '${stats.longestStreak} jours',
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
            title,
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

class _MuscleGroupChart extends StatelessWidget {
  final Map<String, double> muscleGroupVolume;

  const _MuscleGroupChart({required this.muscleGroupVolume});

  @override
  Widget build(BuildContext context) {
    final sections = muscleGroupVolume.entries.map((entry) {
      final percentage = entry.value / muscleGroupVolume.values.reduce((a, b) => a + b) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toInt()}%',
        color: _getMuscleGroupColor(entry.key),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 200,
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
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: muscleGroupVolume.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getMuscleGroupColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getMuscleGroupName(entry.key),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMuscleGroupColor(String muscle) {
    const colors = {
      'chest': Colors.red,
      'back': Colors.blue,
      'shoulders': Colors.orange,
      'legs': Colors.green,
      'arms': Colors.purple,
      'core': Colors.teal,
    };
    return colors[muscle] ?? Colors.grey;
  }

  String _getMuscleGroupName(String muscle) {
    const muscleNames = {
      'chest': 'Pectoraux',
      'back': 'Dos',
      'shoulders': 'Épaules',
      'legs': 'Jambes',
      'arms': 'Bras',
      'core': 'Abdos',
    };
    return muscleNames[muscle] ?? muscle;
  }
}

class _PersonalRecords extends StatelessWidget {
  final List<WorkoutSession> sessions;

  const _PersonalRecords({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Calculer les records (simulation simplifiée)
    final records = _calculateRecords();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: records.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    record['exercise'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${record['weight']}kg × ${record['reps']}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateRecords() {
    // Simulation de calcul de records
    return [
      {'exercise': 'Développé couché', 'weight': 80, 'reps': 5},
      {'exercise': 'Squats', 'weight': 100, 'reps': 8},
      {'exercise': 'Soulevé de terre', 'weight': 120, 'reps': 3},
    ];
  }
}

class _HistoryTab extends StatelessWidget {
  final List<WorkoutSession> sessions;

  const _HistoryTab({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    completedSessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    if (completedSessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64),
            SizedBox(height: 16),
            Text('Aucune séance terminée'),
            Text('Commencez votre premier entraînement !'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedSessions.length,
      itemBuilder: (context, index) {
        final session = completedSessions[index];
        return _SessionHistoryCard(session: session);
      },
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  final WorkoutSession session;

  const _SessionHistoryCard({required this.session});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.workoutName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(session.startTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.duration?.inMinutes ?? 0}min',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${session.totalVolume.toInt()}kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBadge(
                icon: Icons.fitness_center,
                label: '${session.exercises.length} exercices',
              ),
              const SizedBox(width: 8),
              _StatBadge(
                icon: Icons.repeat,
                label: '${session.totalSets} séries',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsTab({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlocked.isNotEmpty) ...[
            Text(
              'Débloqués (${unlocked.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: unlocked.length,
              itemBuilder: (context, index) {
                return AchievementBadge(achievement: unlocked[index]);
              },
            ),
            const SizedBox(height: 24),
          ],
          
          if (locked.isNotEmpty) ...[
            Text(
              'À débloquer (${locked.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: locked.length,
              itemBuilder: (context, index) {
                return AchievementBadge(achievement: locked[index]);
              },
            ),
          ],
        ],
      ),
    );
  }
}