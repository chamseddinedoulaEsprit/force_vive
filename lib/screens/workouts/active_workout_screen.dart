import 'dart:async';
import 'package:flutter/material.dart';
import 'package:force_vive/models/workout.dart';
import 'package:force_vive/models/workout_session.dart';
import 'package:force_vive/models/exercise.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/widgets/achievement_badge.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late WorkoutSession _session;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  Timer? _timer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSecondsRemaining = 0;
  bool _isResting = false;

  final Map<String, List<CompletedSet>> _completedSets = {};

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _startWorkoutTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _initializeSession() {
    _session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: widget.workout.id,
      workoutName: widget.workout.name,
      startTime: DateTime.now(),
      exercises: [],
    );
  }

  void _startWorkoutTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _completeSet(int reps, double weight) {
    final exerciseId = widget.workout.exercises[_currentExerciseIndex].exercise.id;
    final exerciseName = widget.workout.exercises[_currentExerciseIndex].exercise.name;
    
    if (_completedSets[exerciseId] == null) {
      _completedSets[exerciseId] = [];
    }
    
    _completedSets[exerciseId]!.add(CompletedSet(
      reps: reps,
      weight: weight,
      durationSeconds: 0,
      completedAt: DateTime.now(),
    ));

    final currentSet = widget.workout.exercises[_currentExerciseIndex].sets[_currentSetIndex];
    
    // Démarrer le repos si ce n'est pas la dernière série
    if (_currentSetIndex < widget.workout.exercises[_currentExerciseIndex].sets.length - 1) {
      _startRest(currentSet.restSeconds);
    }
    
    _nextSet();
  }

  void _nextSet() {
    setState(() {
      if (_currentSetIndex < widget.workout.exercises[_currentExerciseIndex].sets.length - 1) {
        _currentSetIndex++;
      } else {
        // Passer à l'exercice suivant
        _currentSetIndex = 0;
        if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
          _currentExerciseIndex++;
        } else {
          // Workout terminé
          _completeWorkout();
        }
      }
    });
  }

  void _startRest(int restSeconds) {
    setState(() {
      _isResting = true;
      _restSecondsRemaining = restSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSecondsRemaining--;
        if (_restSecondsRemaining <= 0) {
          _isResting = false;
          timer.cancel();
        }
      });
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsRemaining = 0;
    });
  }

  void _completeWorkout() async {
    _timer?.cancel();
    
    // Créer les exercices de session
    final sessionExercises = _completedSets.entries.map((entry) {
      final exerciseId = entry.key;
      final sets = entry.value;
      final exerciseName = widget.workout.exercises
          .firstWhere((e) => e.exercise.id == exerciseId)
          .exercise.name;
      
      return WorkoutSessionExercise(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        completedSets: sets,
      );
    }).toList();

    final completedSession = WorkoutSession(
      id: _session.id,
      workoutId: _session.workoutId,
      workoutName: _session.workoutName,
      startTime: _session.startTime,
      endTime: DateTime.now(),
      exercises: sessionExercises,
      isCompleted: true,
    );

    await LocalStorageService.saveWorkoutSession(completedSession);
    
    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _WorkoutCompletionDialog(
        session: _session,
        onClose: () {
          Navigator.of(context).pop(); // Fermer le dialog
          Navigator.of(context).pop(); // Retour à l'écran précédent
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentExerciseIndex >= widget.workout.exercises.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWorkoutExercise = widget.workout.exercises[_currentExerciseIndex];
    final currentExercise = currentWorkoutExercise.exercise;
    final currentSet = currentWorkoutExercise.sets[_currentSetIndex];
    final progress = (_currentExerciseIndex + 1) / widget.workout.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentExerciseIndex + 1}/${widget.workout.exercises.length}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          Center(
            child: Text(
              _formatTime(_elapsedSeconds),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          
          Expanded(
            child: _isResting 
                ? _RestScreen(
                    restSecondsRemaining: _restSecondsRemaining,
                    onSkip: _skipRest,
                    nextExercise: _currentExerciseIndex + 1 < widget.workout.exercises.length 
                        ? widget.workout.exercises[_currentExerciseIndex + 1].exercise.name
                        : null,
                  )
                : _ExerciseScreen(
                    exercise: currentExercise,
                    currentSet: currentSet,
                    setNumber: _currentSetIndex + 1,
                    totalSets: currentWorkoutExercise.sets.length,
                    onCompleteSet: _completeSet,
                  ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter l\'entraînement ?'),
        content: const Text('Votre progression sera perdue si vous quittez maintenant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
              Navigator.of(context).pop(); // Quitter l'entraînement
            },
            child: Text(
              'Quitter',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final ExerciseSet currentSet;
  final int setNumber;
  final int totalSets;
  final Function(int reps, double weight) onCompleteSet;

  const _ExerciseScreen({
    required this.exercise,
    required this.currentSet,
    required this.setNumber,
    required this.totalSets,
    required this.onCompleteSet,
  });

  @override
  State<_ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<_ExerciseScreen> {
  late int _reps;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _reps = widget.currentSet.reps;
    _weight = widget.currentSet.weight;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Image et nom de l'exercice
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget.exercise.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.exercise.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.exercise.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Série ${widget.setNumber}/${widget.totalSets}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Contrôles
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _NumberInput(
                        label: 'Répétitions',
                        value: _reps,
                        onChanged: (value) => setState(() => _reps = value),
                        min: 1,
                        max: 50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _NumberInput(
                        label: 'Poids (kg)',
                        value: _weight.toInt(),
                        onChanged: (value) => setState(() => _weight = value.toDouble()),
                        min: 0,
                        max: 200,
                        step: 5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onCompleteSet(_reps, _weight),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.setNumber == widget.totalSets 
                          ? 'Exercice terminé' 
                          : 'Série terminée',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestScreen extends StatelessWidget {
  final int restSecondsRemaining;
  final VoidCallback onSkip;
  final String? nextExercise;

  const _RestScreen({
    required this.restSecondsRemaining,
    required this.onSkip,
    this.nextExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Repos',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${restSecondsRemaining}s',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (nextExercise != null) ...[
              const SizedBox(height: 16),
              Text(
                'Prochain : $nextExercise',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onSkip,
              child: const Text('Passer le repos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  const _NumberInput({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - step) : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: value < max ? () => onChanged(value + step) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutCompletionDialog extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onClose;

  const _WorkoutCompletionDialog({
    required this.session,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Félicitations !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Entraînement terminé avec succès',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Statistiques de la session
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      session.duration?.inMinutes.toString() ?? '0',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'minutes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${session.totalSets}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      'séries',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${session.totalVolume.toInt()}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      'kg soulevés',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Terminer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}