import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/services/supabase_service.dart';

class AssessmentStorageService {
  static const String _assessmentsKey = 'stored_assessments';
  
  // Save a new assessment result
  static Future<bool> saveAssessment(Assessment assessment) async {
    try {
      // Save to local storage as backup
      _saveToLocalStorage(assessment);
      
      // Save to Supabase
      await SupabaseService.saveAssessment(assessment);
      
      return true;
    } catch (e) {
      print('Error saving assessment: $e');
      return false;
    }
  }
  
  // Get all saved assessments
  static Future<List<Assessment>> getAssessments() async {
    try {
      // Try to get from Supabase first
      try {
        final assessments = await SupabaseService.getAssessments();
        return assessments;
      } catch (e) {
        print('Error getting assessments from Supabase: $e');
        // Fallback to local storage
        return _getFromLocalStorage();
      }
    } catch (e) {
      print('Error getting assessments: $e');
      return [];
    }
  }
  
  // Get assessments for a specific child
  static Future<List<Assessment>> getAssessmentsForChild(String childId) async {
    try {
      // Try to get from Supabase first
      try {
        final assessments = await SupabaseService.getAssessmentsForChild(childId);
        return assessments;
      } catch (e) {
        print('Error getting child assessments from Supabase: $e');
        // Fallback to local storage
        final List<Assessment> allAssessments = await _getFromLocalStorage();
        return allAssessments.where((a) => a.childProfileId == childId).toList();
      }
    } catch (e) {
      print('Error getting assessments for child: $e');
      return [];
    }
  }
  
  // Delete an assessment
  static Future<bool> deleteAssessment(String assessmentId) async {
    try {
      // Delete from Supabase
      await SupabaseService.deleteAssessment(assessmentId);
      
      // Also delete from local storage
      _deleteFromLocalStorage(assessmentId);
      
      return true;
    } catch (e) {
      print('Error deleting assessment: $e');
      return false;
    }
  }
  
  // Clear all assessments (for testing/debugging)
  static Future<bool> clearAllAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_assessmentsKey);
      return success;
    } catch (e) {
      print('Error clearing assessments: $e');
      return false;
    }
  }
  
  // Helper methods for local storage as backup
  
  // Save to local storage
  static Future<bool> _saveToLocalStorage(Assessment assessment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing assessments
      final List<Assessment> assessments = await _getFromLocalStorage();
      
      // Add or update the assessment
      final existingIndex = assessments.indexWhere((a) => a.id == assessment.id);
      if (existingIndex != -1) {
        assessments[existingIndex] = assessment;
      } else {
        assessments.add(assessment);
      }
      
      // Convert to JSON and save
      final jsonList = assessments.map((a) => a.toJson()).toList();
      final success = await prefs.setString(_assessmentsKey, jsonEncode(jsonList));
      
      return success;
    } catch (e) {
      print('Error saving assessment to local storage: $e');
      return false;
    }
  }
  
  // Get from local storage
  static Future<List<Assessment>> _getFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_assessmentsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Assessment.fromJson(json)).toList();
    } catch (e) {
      print('Error getting assessments from local storage: $e');
      return [];
    }
  }
  
  // Delete from local storage
  static Future<bool> _deleteFromLocalStorage(String assessmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing assessments
      final List<Assessment> assessments = await _getFromLocalStorage();
      
      // Remove the assessment
      assessments.removeWhere((a) => a.id == assessmentId);
      
      // Convert to JSON and save
      final jsonList = assessments.map((a) => a.toJson()).toList();
      final success = await prefs.setString(_assessmentsKey, jsonEncode(jsonList));
      
      return success;
    } catch (e) {
      print('Error deleting assessment from local storage: $e');
      return false;
    }
  }
} 