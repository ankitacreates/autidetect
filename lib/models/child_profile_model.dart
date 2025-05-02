enum Gender {
  male,
  female,
  other,
  preferNotToSay,
}

class ChildProfile {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final String? ethnicity;
  final bool? familyHistoryOfAutism;
  final bool? jaundiceAtBirth;
  final String parentId;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.ethnicity,
    this.familyHistoryOfAutism,
    this.jaundiceAtBirth,
    required this.parentId,
  });

  ChildProfile copyWith({
    String? id,
    String? name,
    int? age,
    Gender? gender,
    String? ethnicity,
    bool? familyHistoryOfAutism,
    bool? jaundiceAtBirth,
    String? parentId,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      ethnicity: ethnicity ?? this.ethnicity,
      familyHistoryOfAutism: familyHistoryOfAutism ?? this.familyHistoryOfAutism,
      jaundiceAtBirth: jaundiceAtBirth ?? this.jaundiceAtBirth,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender.toString().split('.').last,
      'ethnicity': ethnicity,
      'familyHistoryOfAutism': familyHistoryOfAutism,
      'jaundiceAtBirth': jaundiceAtBirth,
      'parentId': parentId,
    };
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: Gender.values.firstWhere(
        (gender) => gender.toString().split('.').last == json['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
      ethnicity: json['ethnicity'],
      familyHistoryOfAutism: json['familyHistoryOfAutism'],
      jaundiceAtBirth: json['jaundiceAtBirth'],
      parentId: json['parentId'],
    );
  }
} 