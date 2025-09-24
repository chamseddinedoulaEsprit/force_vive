import 'package:flutter/material.dart';
import 'package:force_vive/models/user_profile.dart';
import 'package:force_vive/services/local_storage_service.dart';
import 'package:force_vive/screens/onboarding/goals_setup_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const ProfileSetupScreen({super.key, required this.onComplete});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedGender = 'male';
  String _selectedLevel = 'beginner';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      final basicProfile = {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
        'fitnessLevel': _selectedLevel,
      };

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GoalsSetupScreen(
            basicProfile: basicProfile,
            onComplete: widget.onComplete,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personnalisons votre expérience',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ces informations nous aideront à créer des programmes parfaitement adaptés',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Votre prénom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Genre
              Text(
                'Genre',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'male', label: Text('Homme'), icon: Icon(Icons.male)),
                  ButtonSegment(value: 'female', label: Text('Femme'), icon: Icon(Icons.female)),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedGender = selection.first);
                },
              ),
              const SizedBox(height: 20),

              // Âge et mensurations
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Âge',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                        suffix: Text('ans'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 13 || age > 100) {
                          return 'Âge invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Poids',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                        suffix: Text('kg'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 30 || weight > 300) {
                          return 'Invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Taille',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                  suffix: Text('cm'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre taille';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Taille invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Niveau de fitness
              Text(
                'Votre niveau actuel',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  _LevelCard(
                    title: 'Débutant',
                    description: 'Nouveau dans la musculation ou reprise après une longue pause',
                    value: 'beginner',
                    selectedValue: _selectedLevel,
                    onChanged: (value) => setState(() => _selectedLevel = value),
                  ),
                  const SizedBox(height: 8),
                  _LevelCard(
                    title: 'Intermédiaire',
                    description: '6 mois à 2 ans d\'expérience régulière',
                    value: 'intermediate',
                    selectedValue: _selectedLevel,
                    onChanged: (value) => setState(() => _selectedLevel = value),
                  ),
                  const SizedBox(height: 8),
                  _LevelCard(
                    title: 'Avancé',
                    description: 'Plus de 2 ans d\'entraînement régulier',
                    value: 'advanced',
                    selectedValue: _selectedLevel,
                    onChanged: (value) => setState(() => _selectedLevel = value),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Bouton suivant
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Suivant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _LevelCard({
    required this.title,
    required this.description,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: double.infinity,
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
            Radio<String>(
              value: value,
              groupValue: selectedValue,
              onChanged: (newValue) => onChanged(newValue!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }
}