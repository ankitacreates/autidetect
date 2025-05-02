enum UserType {
  parent,
  caregiver,
  healthcareProfessional,
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserType userType;
  final List<String> childProfileIds;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.childProfileIds = const [],
  });

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserType? userType,
    List<String>? childProfileIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      childProfileIds: childProfileIds ?? this.childProfileIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType.toString().split('.').last,
      'childProfileIds': childProfileIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userType: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == json['userType'],
        orElse: () => UserType.parent,
      ),
      childProfileIds: List<String>.from(json['childProfileIds'] ?? []),
    );
  }
} 