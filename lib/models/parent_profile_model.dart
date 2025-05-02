import 'package:autidetect/models/user_model.dart';

class ParentProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final UserType userType;
  final String? address;
  final List<String> childrenIds;
  final bool hasCompletedOnboarding;

  ParentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.userType,
    this.address,
    this.childrenIds = const [],
    this.hasCompletedOnboarding = false,
  });

  ParentProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    UserType? userType,
    String? address,
    List<String>? childrenIds,
    bool? hasCompletedOnboarding,
  }) {
    return ParentProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      address: address ?? this.address,
      childrenIds: childrenIds ?? this.childrenIds,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType.toString().split('.').last,
      'address': address,
      'childrenIds': childrenIds,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      userType: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == json['userType'],
        orElse: () => UserType.parent,
      ),
      address: json['address'],
      childrenIds: List<String>.from(json['childrenIds'] ?? []),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }
} 