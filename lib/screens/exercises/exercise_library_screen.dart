import 'package:flutter/material.dart';
import 'package:force_vive/models/exercise.dart';
import 'package:force_vive/utils/sample_data.dart';
import 'package:force_vive/widgets/exercise_card.dart';
import 'package:force_vive/screens/exercises/exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscleGroup = 'all';
  String _selectedEquipment = 'all';
  String _selectedDifficulty = 'all';
  
  List<Exercise> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _filteredExercises = SampleData.exercises;
    _searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = SampleData.exercises.where((exercise) {
        final matchesSearch = _searchController.text.isEmpty ||
            exercise.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            exercise.description.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesMuscleGroup = _selectedMuscleGroup == 'all' ||
            exercise.muscleGroups.contains(_selectedMuscleGroup);
        
        final matchesEquipment = _selectedEquipment == 'all' ||
            exercise.equipment == _selectedEquipment;
        
        final matchesDifficulty = _selectedDifficulty == 'all' ||
            exercise.difficulty == _selectedDifficulty;

        return matchesSearch && matchesMuscleGroup && matchesEquipment && matchesDifficulty;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedMuscleGroup = 'all';
      _selectedEquipment = 'all';
      _selectedDifficulty = 'all';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque d\'exercices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),

          // Filtres actifs
          if (_selectedMuscleGroup != 'all' || _selectedEquipment != 'all' || _selectedDifficulty != 'all')
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (_selectedMuscleGroup != 'all')
                          _FilterChip(
                            label: _getMuscleGroupName(_selectedMuscleGroup),
                            onDeleted: () => setState(() => _selectedMuscleGroup = 'all'),
                          ),
                        if (_selectedEquipment != 'all')
                          _FilterChip(
                            label: _getEquipmentName(_selectedEquipment),
                            onDeleted: () => setState(() => _selectedEquipment = 'all'),
                          ),
                        if (_selectedDifficulty != 'all')
                          _FilterChip(
                            label: _getDifficultyName(_selectedDifficulty),
                            onDeleted: () => setState(() => _selectedDifficulty = 'all'),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
            ),

          // Liste des exercices
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun exercice trouvé',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez d\'ajuster vos filtres',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExerciseCard(
                          exercise: exercise,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtres',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _resetFilters();
                      setModalState(() {});
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Groupe musculaire
              Text(
                'Groupe musculaire',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['all', 'chest', 'back', 'shoulders', 'arms', 'legs', 'glutes', 'core']
                    .map((muscle) => FilterChip(
                          label: Text(_getMuscleGroupName(muscle)),
                          selected: _selectedMuscleGroup == muscle,
                          onSelected: (selected) {
                            setState(() => _selectedMuscleGroup = muscle);
                            setModalState(() {});
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Équipement
              Text(
                'Équipement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['all', 'bodyweight', 'dumbbells', 'barbell', 'pull_up_bar']
                    .map((equipment) => FilterChip(
                          label: Text(_getEquipmentName(equipment)),
                          selected: _selectedEquipment == equipment,
                          onSelected: (selected) {
                            setState(() => _selectedEquipment = equipment);
                            setModalState(() {});
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Difficulté
              Text(
                'Difficulté',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['all', 'beginner', 'intermediate', 'advanced']
                    .map((difficulty) => FilterChip(
                          label: Text(_getDifficultyName(difficulty)),
                          selected: _selectedDifficulty == difficulty,
                          onSelected: (selected) {
                            setState(() => _selectedDifficulty = difficulty);
                            setModalState(() {});
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _filterExercises();
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMuscleGroupName(String muscle) {
    const muscleNames = {
      'all': 'Tous',
      'chest': 'Pectoraux',
      'back': 'Dos',
      'shoulders': 'Épaules',
      'arms': 'Bras',
      'legs': 'Jambes',
      'glutes': 'Fessiers',
      'core': 'Abdos',
    };
    return muscleNames[muscle] ?? muscle;
  }

  String _getEquipmentName(String equipment) {
    const equipmentNames = {
      'all': 'Tous',
      'bodyweight': 'Poids du corps',
      'dumbbells': 'Haltères',
      'barbell': 'Barre',
      'pull_up_bar': 'Barre de traction',
    };
    return equipmentNames[equipment] ?? equipment;
  }

  String _getDifficultyName(String difficulty) {
    const difficultyNames = {
      'all': 'Tous',
      'beginner': 'Débutant',
      'intermediate': 'Intermédiaire',
      'advanced': 'Avancé',
    };
    return difficultyNames[difficulty] ?? difficulty;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      ),
    );
  }
}