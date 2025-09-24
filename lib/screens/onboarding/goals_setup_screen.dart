import 'package:flutter/material.dart';
import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/utils/sample_data.dart';

class GoalsSetupScreen extends StatefulWidget {
  final Map<String, dynamic> basicProfile;
  final VoidCallback onComplete;

  const GoalsSetupScreen({
    super.key,
    required this.basicProfile,
    required this.onComplete,
  });

  @override
  State<GoalsSetupScreen> createState() => _GoalsSetupScreenState();
}

class _GoalsSetupScreenState extends State<GoalsSetupScreen> {
  final Set<String> _selectedGoals = {};
  final Set<String> _selectedEquipment = {};
  int _workoutDays = 3;
  int _workoutDuration = 45;

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'muscle_gain',
      'title': 'Prise de masse',
      'description': 'Développer et tonifier les muscles',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'weight_loss',
      'title': 'Perte de poids',
      'description': 'Brûler les graisses et affiner la silhouette',
      'icon': Icons.local_fire_department,
    },
    {
      'id': 'strength',
      'title': 'Force',
      'description': 'Augmenter la force et la puissance',
      'icon': Icons.sports_gymnastics,
    },
    {
      'id': 'endurance',
      'title': 'Endurance',
      'description': 'Améliorer la condition cardiovasculaire',
      'icon': Icons.directions_run,
    },
  ];

  final List<Map<String, dynamic>> _equipment = [
    {
      'id': 'bodyweight',
      'title': 'Poids du corps',
      'description': 'Aucun équipement nécessaire',
      'icon': Icons.accessibility_new,
    },
    {
      'id': 'dumbbells',
      'title': 'Haltères',
      'description': 'Haltères ajustables ou fixes',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'barbell',
      'title': 'Barre et poids',
      'description': 'Barre olympique avec disques',
      'icon': Icons.straighten,
    },
    {
      'id': 'pull_up_bar',
      'title': 'Barre de traction',
      'description': 'Pour tractions et exercices suspendus',
      'icon': Icons.horizontal_rule,
    },
  ];

  Future<void> _completeSetup() async {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un objectif')),
      );
      return;
    }

    if (_selectedEquipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un équipement')),
      );
      return;
    }

    final profile = UserProfile(
      name: widget.basicProfile['name'],
      age: widget.basicProfile['age'],
      gender: widget.basicProfile['gender'],
      weight: widget.basicProfile['weight'],
      height: widget.basicProfile['height'],
      fitnessLevel: widget.basicProfile['fitnessLevel'],
      goals: _selectedGoals.toList(),
      availableEquipment: _selectedEquipment.toList(),
      workoutDaysPerWeek: _workoutDays,
      workoutDurationMinutes: _workoutDuration,
    );

    // Sauvegarder le profil et marquer l'onboarding comme terminé
    await LocalStorageService.saveUserProfile(profile);
    await LocalStorageService.setOnboardingCompleted(true);
    
    // Initialiser les achievements
    await LocalStorageService.saveAchievements(SampleData.achievements);

    // Notifier le parent et revenir à l'écran racine (MainNavigation)
    widget.onComplete();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos Objectifs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Définissons vos objectifs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez un ou plusieurs objectifs pour personnaliser vos programmes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Objectifs
            Text(
              'Mes objectifs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._goals.map((goal) => _GoalCard(
              goal: goal,
              isSelected: _selectedGoals.contains(goal['id']),
              onToggle: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGoals.add(goal['id']);
                  } else {
                    _selectedGoals.remove(goal['id']);
                  }
                });
              },
            )),

            const SizedBox(height: 32),

            // Équipement disponible
            Text(
              'Équipement disponible',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._equipment.map((equipment) => _EquipmentCard(
              equipment: equipment,
              isSelected: _selectedEquipment.contains(equipment['id']),
              onToggle: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(equipment['id']);
                  } else {
                    _selectedEquipment.remove(equipment['id']);
                  }
                });
              },
            )),

            const SizedBox(height: 32),

            // Préférences d'entraînement
            Text(
              'Préférences d\'entraînement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Fréquence
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Séances par semaine',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 2, label: Text('2')),
                        ButtonSegment(value: 3, label: Text('3')),
                        ButtonSegment(value: 4, label: Text('4')),
                        ButtonSegment(value: 5, label: Text('5+')),
                      ],
                      selected: {_workoutDays},
                      onSelectionChanged: (Set<int> selection) {
                        setState(() => _workoutDays = selection.first);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Durée
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Durée par séance',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 30, label: Text('30min')),
                        ButtonSegment(value: 45, label: Text('45min')),
                        ButtonSegment(value: 60, label: Text('60min')),
                      ],
                      selected: {_workoutDuration},
                      onSelectionChanged: (Set<int> selection) {
                        setState(() => _workoutDuration = selection.first);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton terminer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeSetup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Commencer l\'aventure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onToggle(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                goal['icon'],
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                    Text(
                      goal['description'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Map<String, dynamic> equipment;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const _EquipmentCard({
    required this.equipment,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onToggle(!isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.secondary 
                  : Theme.of(context).colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                equipment['icon'],
                color: isSelected 
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment['title'],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.secondary : null,
                      ),
                    ),
                    Text(
                      equipment['description'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}