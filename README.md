
# Force Vive

**Force Vive** est une application d'entraînement en musculation conçue pour aider les utilisateurs de tous niveaux à s'entraîner efficacement, suivre leurs progrès et rester motivés grâce à une expérience interactive et personnalisée.

## Aperçu

Force Vive propose :  
- Onboarding personnalisé (profil, objectifs, niveau).  
- Génération intelligente de programmes d'entraînement.  
- Bibliothèque d'exercices avec détails et images.  
- Suivi des séances en temps réel et historique des entraînements.  
- Statistiques et graphiques de progression.  
- Système de gamification (badges / achievements).  

**Statut :** fonctionnalité complète côté UI. Aucun backend n'est connecté par défaut (voir section Backend).

## Fonctionnalités clés

- Écran d'accueil avec recommandations et séances récentes  
- Bibliothèque d'exercices (fiches d'exercices détaillées)  
- Programmes d'entraînement et détails de séance  
- Suivi en temps réel des séances (timer, sets, répétitions)  
- Écran Progression avec graphiques  
- Onboarding complet (profil + objectifs)  
- Gamification avec badges  
- Stockage local (pour données utilisateurs et sessions)  

## Utiliser le projet dans Dreamflow (recommandé)

Ce projet a été créé pour fonctionner dans l'éditeur visuel Dreamflow. Pour explorer et tester l'application sans configuration locale :

1. Ouvre le projet dans Dreamflow.
2. Utilise le panneau Preview pour lancer l'app dans le navigateur.
3. Active Inspect Mode si tu veux sélectionner et éditer visuellement des widgets.
4. Édite des fichiers depuis le panneau Code.
5. Utilise Hot Reload ou Hot Restart depuis l'interface pour voir les changements.
6. Pour ajouter/mettre à jour des images, ouvre le panneau Assets et utilise le bouton "+" pour téléverser.

### Remarques utiles :

- Si tu veux connecter un backend (Firebase ou Supabase), ouvre le panneau Firebase ou Supabase dans Dreamflow et complète la configuration via l'interface (Dreamflow gère l'intégration).  
- Pour envoyer un rapport de bug ou une demande d'amélioration, clique sur "Submit Feedback" dans la barre supérieure de Dreamflow.

## Configuration backend

Aucun backend n'est connecté par défaut.

- Pour utiliser Firebase : ouvre le panneau Firebase dans Dreamflow et suis l'assistant de connexion et d'intégration.  
- Pour utiliser Supabase : ouvre le panneau Supabase et suis l'assistant.  

## Structure du projet

- **lib/main.dart** — point d'entrée.  
- **lib/theme.dart** — thèmes et styles.  
- **lib/screens/** — écrans de l'application (onboarding, home, exercises, workouts, progress, profile).  
- **lib/widgets/** — composants réutilisables (cards, charts, badges).  
- **lib/models/** — modèles de données (Workout, Exercise, UserProfile, Achievement…).  
- **lib/services/** — services locaux : génération de programmes, stockage local, calculs de stats.  
- **lib/utils/sample_data.dart** — données d'exemple.  
- **pubspec.yaml** — dépendances et assets.  
- **assets/** — images et médias utilisés par l'app.  

## Tests et scénarios importants

- **Onboarding** : vérifie la saisie du profil (âge, poids, taille, objectifs) et que le bouton "Commencer l'aventure" renvoie bien à l'écran principal.  
- **Génération de programme** : teste la création d'un programme avec différents niveaux et objectifs.  
- **Suivi de séance** : démarre une séance, enregistre sets/répétitions et vérifie l'historique.  
- **Progression** : vérifie les graphiques et la cohérence des statistiques.  

## Personnalisation rapide

- Modifier le thème : édite `lib/theme.dart`.  
- Mettre à jour ou ajouter un exercice : ajoute un modèle dans `lib/models/exercise.dart` puis référence une image via Assets.  
- Ajouter une image : panneau Assets → upload → utiliser le nom de fichier dans le code.  

## Exécuter localement (optionnel)

Télécharge le code depuis Dreamflow (Menu > Download Code) pour l'ouvrir localement dans ton environnement Flutter.  
Utilise ton IDE/outil habituel pour builder et déployer sur simulateur/appareil.  

## Contribution

- Ouvrir une issue ou utiliser le bouton "Submit Feedback" dans Dreamflow pour rapports de bugs ou demandes d'amélioration.  
- Pour modifications de code importantes, crée une branche dédiée et propose une MR (ou fournis des instructions pour revue).  

## Points connus / TODO

- Aucun backend connecté par défaut : stockage actuellement local.  
- Possibilité d'ajouter synchronisation cloud (Firebase/Supabase) via les panels Dreamflow.  
- Extension d'exercices et médias (plus d'images/vidéos).  
- Améliorations UX pour la planification avancée et notifications.  

## Licence

Ajoute ici la licence que tu souhaites (ex. MIT, Apache 2.0). Exemple : MIT License — voir fichier LICENSE pour les détails.
