class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double weight; // kg
  final double height; // cm
  final String fitnessLevel; // beginner, intermediate, advanced
  final List<String> goals; // weight_loss, muscle_gain, strength, endurance
  final List<String> availableEquipment;
  final int workoutDaysPerWeek;
  final int workoutDurationMinutes;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.fitnessLevel,
    required this.goals,
    required this.availableEquipment,
    required this.workoutDaysPerWeek,
    required this.workoutDurationMinutes,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'weight': weight,
    'height': height,
    'fitnessLevel': fitnessLevel,
    'goals': goals,
    'availableEquipment': availableEquipment,
    'workoutDaysPerWeek': workoutDaysPerWeek,
    'workoutDurationMinutes': workoutDurationMinutes,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    age: json['age'] ?? 25,
    gender: json['gender'] ?? 'male',
    weight: json['weight']?.toDouble() ?? 70.0,
    height: json['height']?.toDouble() ?? 170.0,
    fitnessLevel: json['fitnessLevel'] ?? 'beginner',
    goals: List<String>.from(json['goals'] ?? ['muscle_gain']),
    availableEquipment: List<String>.from(json['availableEquipment'] ?? ['bodyweight']),
    workoutDaysPerWeek: json['workoutDaysPerWeek'] ?? 3,
    workoutDurationMinutes: json['workoutDurationMinutes'] ?? 45,
  );

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Sous-poids';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }
}