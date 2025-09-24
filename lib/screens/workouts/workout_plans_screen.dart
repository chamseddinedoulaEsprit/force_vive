import 'package:flutter/material.dart';
import 'package:force_vive/models/workout.dart';
import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/services/workout_generator_service.dart';
import 'package:force_vive/widgets/workout_card.dart';
import 'package:force_vive/screens/workouts/workout_detail_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _profile;
  List<Workout> _recommendedWorkouts = [];
  List<Workout> _customWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final profile = await LocalStorageService.getUserProfile();
    if (profile != null) {
      final recommendedWorkouts = WorkoutGeneratorService.generateWorkoutPlan(profile);
      setState(() {
        _profile = profile;
        _recommendedWorkouts = recommendedWorkouts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64),
              SizedBox(height: 16),
              Text('Profil non trouvé'),
              Text('Veuillez compléter votre onboarding'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmes d\'entraînement'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recommandés', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Mes programmes', icon: Icon(Icons.bookmark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Créer un nouveau programme
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Création de programme bientôt disponible')),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecommendedWorkoutsTab(workouts: _recommendedWorkouts),
          _CustomWorkoutsTab(workouts: _customWorkouts),
        ],
      ),
    );
  }
}

class _RecommendedWorkoutsTab extends StatelessWidget {
  final List<Workout> workouts;

  const _RecommendedWorkoutsTab({required this.workouts});

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_outlined, size: 64),
            SizedBox(height: 16),
            Text('Aucun programme recommandé'),
            Text('Vérifiez votre profil et équipement'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Recharger les programmes
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _HeaderSection();
          }
          
          final workout = workouts[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: WorkoutCard(
              workout: workout,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailScreen(workout: workout),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CustomWorkoutsTab extends StatelessWidget {
  final List<Workout> workouts;

  const _CustomWorkoutsTab({required this.workouts});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Créez votre premier programme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personnalisez vos entraînements selon vos besoins',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigation vers la création de programme
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité bientôt disponible')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer un programme'),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Programmes personnalisés',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Basés sur votre profil, niveau et équipement disponible',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cartes d'information
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.psychology,
                  title: 'IA Adaptative',
                  description: 'Programmes qui évoluent avec vous',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.schedule,
                  title: 'Flexibilité',
                  description: 'Durées adaptées à votre emploi du temps',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}