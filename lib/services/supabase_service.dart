import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autidetect/models/user_model.dart' as app_models;
import 'package:autidetect/models/child_profile_model.dart';
import 'package:autidetect/models/assessment_model.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception('Supabase URL or API key not found. Please check your .env file.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: kDebugMode,
    );

    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required app_models.UserType userType,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType.toString().split('.').last,
      },
    );
    
    if (response.user != null) {
      // Create user profile in the database
      try {
        // First set the auth token to use the new user's credentials 
        // This allows them to create their own profile with the correct RLS permissions
        await client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'user_type': userType.toString().split('.').last,
        });
        
        print('User profile created successfully');
      } catch (e) {
        print('Error creating user profile: $e');
        // Even if profile creation fails, we return the auth response
        // The profile can be created later when the user logs in
      }
    }
    
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Ensure the user has a profile in the database
      await getCurrentUser();
    }
    
    return response;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<app_models.User?> getCurrentUser() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return null;

    try {
      // Try to get the user profile
      final response = await client
          .from('users')
          .select('*, child_profiles:child_profiles(id)')
          .eq('id', authUser.id)
          .maybeSingle();

      // If user profile doesn't exist in the database, create it
      if (response == null) {
        // This can happen if signup failed to create the profile
        // but the auth account was created successfully
        final userData = authUser.userMetadata;
        if (userData != null) {
          // Create user profile from auth metadata
          final userType = userData['userType'] as String? ?? 'parent';
          final firstName = userData['firstName'] as String? ?? '';
          final lastName = userData['lastName'] as String? ?? '';
          
          try {
            await client.from('users').insert({
              'id': authUser.id,
              'email': authUser.email ?? '',
              'first_name': firstName,
              'last_name': lastName,
              'user_type': userType,
            });
            
            // Try to get the user again
            return await getCurrentUser();
          } catch (e) {
            print('Error creating missing user profile: $e');
            return null;
          }
        }
        return null;
      }

      List<String> childProfileIds = [];
      if (response['child_profiles'] != null) {
        childProfileIds = (response['child_profiles'] as List)
            .map((child) => child['id'] as String)
            .toList();
      }

      return app_models.User(
        id: response['id'],
        email: response['email'],
        firstName: response['first_name'],
        lastName: response['last_name'],
        userType: app_models.UserType.values.firstWhere(
          (type) => type.toString().split('.').last == response['user_type'],
          orElse: () => app_models.UserType.parent,
        ),
        childProfileIds: childProfileIds,
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Child Profile methods
  static Future<List<ChildProfile>> getChildProfiles(String userId) async {
    final response = await client
        .from('child_profiles')
        .select()
        .eq('parent_id', userId);

    return (response as List)
        .map((json) => ChildProfile(
              id: json['id'],
              name: json['name'],
              age: json['age'],
              gender: Gender.values.firstWhere(
                (gender) => gender.toString().split('.').last == json['gender'],
                orElse: () => Gender.preferNotToSay,
              ),
              ethnicity: json['ethnicity'],
              familyHistoryOfAutism: json['family_history_of_autism'],
              jaundiceAtBirth: json['jaundice_at_birth'],
              parentId: json['parent_id'],
            ))
        .toList();
  }

  static Future<ChildProfile> createChildProfile(ChildProfile profile) async {
    final response = await client.from('child_profiles').insert({
      'id': profile.id,
      'name': profile.name,
      'age': profile.age,
      'gender': profile.gender.toString().split('.').last,
      'ethnicity': profile.ethnicity,
      'family_history_of_autism': profile.familyHistoryOfAutism,
      'jaundice_at_birth': profile.jaundiceAtBirth,
      'parent_id': profile.parentId,
    }).select();

    return ChildProfile.fromJson({
      'id': response[0]['id'],
      'name': response[0]['name'],
      'age': response[0]['age'],
      'gender': response[0]['gender'],
      'ethnicity': response[0]['ethnicity'],
      'familyHistoryOfAutism': response[0]['family_history_of_autism'],
      'jaundiceAtBirth': response[0]['jaundice_at_birth'],
      'parentId': response[0]['parent_id'],
    });
  }

  static Future<void> updateChildProfile(ChildProfile profile) async {
    await client.from('child_profiles').update({
      'name': profile.name,
      'age': profile.age,
      'gender': profile.gender.toString().split('.').last,
      'ethnicity': profile.ethnicity,
      'family_history_of_autism': profile.familyHistoryOfAutism,
      'jaundice_at_birth': profile.jaundiceAtBirth,
    }).eq('id', profile.id);
  }

  static Future<void> deleteChildProfile(String profileId) async {
    await client.from('child_profiles').delete().eq('id', profileId);
  }

  // Assessment methods
  static Future<List<Assessment>> getAssessments() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return [];

    final response = await client
        .from('assessments')
        .select('*, child_profiles!inner(parent_id)')
        .eq('child_profiles.parent_id', authUser.id);

    return (response as List)
        .map((json) => Assessment(
              id: json['id'],
              childProfileId: json['child_profile_id'],
              type: AssessmentType.values.firstWhere(
                (type) => type.toString().split('.').last == json['type'],
                orElse: () => AssessmentType.toddler,
              ),
              status: AssessmentStatus.values.firstWhere(
                (status) => status.toString().split('.').last == json['status'],
                orElse: () => AssessmentStatus.notStarted,
              ),
              createdAt: json['created_at'] != null 
                  ? DateTime.parse(json['created_at']) 
                  : null,
              completedAt: json['completed_at'] != null 
                  ? DateTime.parse(json['completed_at']) 
                  : null,
              scheduledFor: json['scheduled_for'] != null 
                  ? DateTime.parse(json['scheduled_for']) 
                  : null,
              likelihood: AutismLikelihood.values.firstWhere(
                (likelihood) => likelihood.toString().split('.').last == json['likelihood'],
                orElse: () => AutismLikelihood.unknown,
              ),
              qualityScore: json['quality_score'],
              videoPath: json['video_path'],
              questionnaireResponses: json['questionnaire_responses'],
            ))
        .toList();
  }

  static Future<List<Assessment>> getAssessmentsForChild(String childId) async {
    final response = await client
        .from('assessments')
        .select()
        .eq('child_profile_id', childId);

    return (response as List)
        .map((json) => Assessment(
              id: json['id'],
              childProfileId: json['child_profile_id'],
              type: AssessmentType.values.firstWhere(
                (type) => type.toString().split('.').last == json['type'],
                orElse: () => AssessmentType.toddler,
              ),
              status: AssessmentStatus.values.firstWhere(
                (status) => status.toString().split('.').last == json['status'],
                orElse: () => AssessmentStatus.notStarted,
              ),
              createdAt: json['created_at'] != null 
                  ? DateTime.parse(json['created_at']) 
                  : null,
              completedAt: json['completed_at'] != null 
                  ? DateTime.parse(json['completed_at']) 
                  : null,
              scheduledFor: json['scheduled_for'] != null 
                  ? DateTime.parse(json['scheduled_for']) 
                  : null,
              likelihood: AutismLikelihood.values.firstWhere(
                (likelihood) => likelihood.toString().split('.').last == json['likelihood'],
                orElse: () => AutismLikelihood.unknown,
              ),
              qualityScore: json['quality_score'],
              videoPath: json['video_path'],
              questionnaireResponses: json['questionnaire_responses'],
            ))
        .toList();
  }

  static Future<Assessment> saveAssessment(Assessment assessment) async {
    // Check if assessment exists
    final exists = await client
        .from('assessments')
        .select('id')
        .eq('id', assessment.id)
        .maybeSingle();

    Map<String, dynamic> data = {
      'child_profile_id': assessment.childProfileId,
      'type': assessment.type.toString().split('.').last,
      'status': assessment.status.toString().split('.').last,
      'created_at': assessment.createdAt?.toIso8601String(),
      'completed_at': assessment.completedAt?.toIso8601String(),
      'scheduled_for': assessment.scheduledFor?.toIso8601String(),
      'likelihood': assessment.likelihood.toString().split('.').last,
      'quality_score': assessment.qualityScore,
      'video_path': assessment.videoPath,
      'questionnaire_responses': assessment.questionnaireResponses,
    };

    if (exists == null) {
      // Create new assessment
      data['id'] = assessment.id;
      final response = await client.from('assessments').insert(data).select();
      return Assessment.fromJson(_mapSupabaseToAssessment(response[0]));
    } else {
      // Update existing assessment
      final response = await client.from('assessments').update(data).eq('id', assessment.id).select();
      return Assessment.fromJson(_mapSupabaseToAssessment(response[0]));
    }
  }

  static Future<void> deleteAssessment(String assessmentId) async {
    await client.from('assessments').delete().eq('id', assessmentId);
  }

  // Helper function to map Supabase response to Assessment model
  static Map<String, dynamic> _mapSupabaseToAssessment(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'childProfileId': data['child_profile_id'],
      'type': data['type'],
      'status': data['status'],
      'createdAt': data['created_at'],
      'completedAt': data['completed_at'],
      'scheduledFor': data['scheduled_for'],
      'likelihood': data['likelihood'],
      'qualityScore': data['quality_score'],
      'videoPath': data['video_path'],
      'questionnaireResponses': data['questionnaire_responses'],
    };
  }

  static Future<bool> updateUserType(String userId, app_models.UserType userType) async {
    try {
      await client.from('users').update({
        'user_type': userType.toString().split('.').last
      }).eq('id', userId);
      
      return true;
    } catch (e) {
      print('Error updating user type: $e');
      return false;
    }
  }
} 