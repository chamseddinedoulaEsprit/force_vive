# Architecture Force Vive - Application Musculation

## Vue d'ensemble
Application mobile complète de musculation avec coaching virtuel, suivi des progrès et gamification pour motiver les utilisateurs de tout niveau.

## Fonctionnalités principales (MVP)
1. **Onboarding et profil utilisateur** - Configuration initiale personnalisée
2. **Bibliothèque d'exercices** - Catalogue d'exercices avec filtres
3. **Programmes d'entraînement** - Plans pré-définis et personnalisés  
4. **Suivi des séances** - Enregistrement en temps réel des performances
5. **Statistiques et progrès** - Graphiques et métriques détaillées
6. **Gamification** - Badges, défis et motivation
7. **Communauté** - Partage et échanges entre utilisateurs
8. **Coach virtuel** - IA pour conseils personnalisés

## Architecture technique

### Structure des fichiers
```
lib/
├── main.dart
├── theme.dart
├── models/
│   ├── user_profile.dart
│   ├── exercise.dart
│   ├── workout.dart
│   ├── workout_session.dart
│   └── achievement.dart
├── screens/
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   ├── profile_setup_screen.dart
│   │   └── goals_setup_screen.dart
│   ├── main_navigation.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── exercises/
│   │   ├── exercise_library_screen.dart
│   │   └── exercise_detail_screen.dart
│   ├── workouts/
│   │   ├── workout_plans_screen.dart
│   │   ├── workout_detail_screen.dart
│   │   └── active_workout_screen.dart
│   ├── progress/
│   │   └── progress_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── services/
│   ├── local_storage_service.dart
│   ├── workout_generator_service.dart
│   └── stats_calculator_service.dart
├── widgets/
│   ├── exercise_card.dart
│   ├── workout_card.dart
│   ├── progress_chart.dart
│   └── achievement_badge.dart
└── utils/
    └── sample_data.dart
```

### Modèles de données
- **UserProfile**: informations personnelles, objectifs, niveau
- **Exercise**: nom, description, groupes musculaires, équipement
- **Workout**: collection d'exercices avec séries/répétitions
- **WorkoutSession**: enregistrement d'une séance complétée
- **Achievement**: système de badges et récompenses

### Navigation
Navigation par onglets avec 5 sections principales:
1. Accueil - Vue d'ensemble et démarrage rapide
2. Exercices - Bibliothèque avec filtres
3. Programmes - Plans d'entraînement
4. Progrès - Statistiques et graphiques
5. Profil - Paramètres utilisateur et achievements

### Stockage des données
Utilisation du stockage local (SharedPreferences) pour:
- Profil utilisateur
- Historique des séances
- Données de progression
- Préférences de l'application

### Design
- Couleurs énergiques adaptées au fitness (bleu, orange, vert)
- Design Material 3 moderne et épuré
- Navigation intuitive (max 3 clics)
- Interface adaptée au mode hors-ligne

## Implémentation par étapes

1. **Setup initial**: Mise à jour du thème et dépendances
2. **Modèles de données**: Création des structures de données
3. **Services**: Logique métier et stockage local
4. **Navigation**: Structure principale avec onglets
5. **Onboarding**: Écrans de première utilisation
6. **Écrans principaux**: Implémentation des fonctionnalités core
7. **Widgets réutilisables**: Composants UI communs
8. **Données d'exemple**: Contenu réaliste pour démonstration
9. **Tests et optimisation**: Compilation et corrections

## Technologies utilisées
- Flutter (cross-platform)
- Material 3 Design
- SharedPreferences (stockage local)
- Google Fonts (typographie)
- Charts (graphiques de progression)