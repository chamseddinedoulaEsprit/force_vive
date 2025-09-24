import 'package:flutter/material.dart';
import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/models/workout_session.dart';
import 'package:force_vive/models/achievement.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/services/workout_generator_service.dart';
import 'package:force_vive/services/stats_calculator_service.dart';
import 'package:force_vive/widgets/workout_card.dart';
import 'package:force_vive/widgets/achievement_badge.dart';
import 'package:force_vive/screens/workouts/workout_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  UserStats _stats = UserStats();
  List<WorkoutSession> _recentSessions = [];
  List<Achievement> _unlockedAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await LocalStorageService.getUserProfile();
    final sessions = await LocalStorageService.getRecentSessions(limit: 5);
    final stats = StatsCalculatorService.calculateUserStats(sessions);
    final achievements = await LocalStorageService.getAchievements();
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();

    setState(() {
      _profile = profile;
      _stats = stats;
      _recentSessions = sessions;
      _unlockedAchievements = unlockedAchievements;
      _isLoading = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _getMotivationalMessage() {
    if (_stats.totalWorkouts == 0) {
      return 'Prêt pour votre première séance ?';
    }
    if (_stats.currentStreak == 0) {
      return 'Il est temps de reprendre le rythme !';
    }
    if (_stats.currentStreak >= 7) {
      return 'Incroyable streak de ${_stats.currentStreak} jours ! 🔥';
    }
    return 'Continuez sur cette lancée !';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar avec salutation
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${_getGreeting()}, ${_profile!.name}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMotivationalMessage(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contenu principal
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Statistiques rapides
                  _StatsOverview(stats: _stats),
                  const SizedBox(height: 24),

                  // Workout recommandé
                  _RecommendedWorkout(profile: _profile!),
                  const SizedBox(height: 24),

                  // Achievements récents
                  if (_unlockedAchievements.isNotEmpty) ...[
                    Text(
                      'Achievements récents',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _unlockedAchievements.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: index == _unlockedAchievements.length - 1 ? 0 : 12),
                            child: AchievementBadge(achievement: _unlockedAchievements[index]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Historique récent
                  if (_recentSessions.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Séances récentes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigation vers l'onglet progrès
                          },
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._recentSessions.take(3).map((session) => _SessionCard(session: session)),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final UserStats stats;

  const _StatsOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos performances',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.fitness_center,
                  value: '${stats.totalWorkouts}',
                  label: 'Séances',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department,
                  value: '${stats.currentStreak}',
                  label: 'Streak',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.trending_up,
                  value: '${stats.totalVolumeLifted.toInt()}kg',
                  label: 'Volume',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _RecommendedWorkout extends StatelessWidget {
  final UserProfile profile;

  const _RecommendedWorkout({required this.profile});

  @override
  Widget build(BuildContext context) {
    final recommendedWorkout = WorkoutGeneratorService.getRecommendedWorkout(profile, []);
    
    if (recommendedWorkout == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout recommandé',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        WorkoutCard(
          workout: recommendedWorkout,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WorkoutDetailScreen(workout: recommendedWorkout),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: session.isCompleted 
                  ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              session.isCompleted ? Icons.check_circle : Icons.schedule,
              color: session.isCompleted 
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.outline,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.workoutName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(session.startTime)} • ${session.totalSets} séries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (session.isCompleted)
            Text(
              '${session.totalVolume.toInt()}kg',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
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
    return '${date.day}/${date.month}';
  }
}