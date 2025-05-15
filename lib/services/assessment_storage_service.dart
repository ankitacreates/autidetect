import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/services/supabase_service.dart';

class AssessmentStorageService {
  static const String _assessmentsKey = 'stored_assessments';
  static const String _syncEnabledKey = 'sync_enabled';
  
  // Check if cloud sync is enabled
  static Future<bool> isSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncEnabledKey) ?? false;
  }
  
  // Enable or disable cloud sync
  static Future<bool> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_syncEnabledKey, enabled);
  }
  
  // Save a new assessment result
  static Future<bool> saveAssessment(Assessment assessment) async {
    try {
      // Always save to local storage first
      await _saveToLocalStorage(assessment);
      
      // If sync is enabled, also save to Supabase
      if (await isSyncEnabled()) {
        try {
      await SupabaseService.saveAssessment(assessment);
        } catch (e) {
          print('Error saving to cloud, but saved locally: $e');
          // We don't consider this a failure since local storage worked
        }
      }
      
      return true;
    } catch (e) {
      print('Error saving assessment: $e');
      return false;
    }
  }
  
  // Get all saved assessments
  static Future<List<Assessment>> getAssessments() async {
    try {
      // Always get from local storage first
      final localAssessments = await _getFromLocalStorage();
      
      // If sync is enabled, try to merge with cloud data
      if (await isSyncEnabled()) {
      try {
          final cloudAssessments = await SupabaseService.getAssessments();
          
          // Merge assessments, prioritizing newer versions
          final Map<String, Assessment> mergedMap = {};
          
          // Add local assessments first
          for (final assessment in localAssessments) {
            mergedMap[assessment.id] = assessment;
          }
          
          // Add or update with cloud assessments if they're newer
          for (final assessment in cloudAssessments) {
            final existingAssessment = mergedMap[assessment.id];
            if (existingAssessment == null || 
                (assessment.completedAt != null && 
                 existingAssessment.completedAt != null &&
                 assessment.completedAt!.isAfter(existingAssessment.completedAt!))) {
              mergedMap[assessment.id] = assessment;
            }
          }
          
          // Save the merged data back to local storage
          final List<Assessment> mergedList = mergedMap.values.toList();
          for (final assessment in mergedList) {
            await _saveToLocalStorage(assessment);
          }
          
          return mergedList;
      } catch (e) {
          print('Error syncing with cloud, using local data: $e');
          return localAssessments;
        }
      }
      
      return localAssessments;
    } catch (e) {
      print('Error getting assessments: $e');
      return [];
    }
  }
  
  // Get assessments for a specific child
  static Future<List<Assessment>> getAssessmentsForChild(String childId) async {
    try {
      final List<Assessment> allAssessments = await getAssessments();
        return allAssessments.where((a) => a.childProfileId == childId).toList();
    } catch (e) {
      print('Error getting assessments for child: $e');
      return [];
    }
  }
  
  // Delete an assessment
  static Future<bool> deleteAssessment(String assessmentId) async {
    try {
      // Always delete from local storage
      await _deleteFromLocalStorage(assessmentId);
      
      // If sync is enabled, also delete from cloud
      if (await isSyncEnabled()) {
        try {
      await SupabaseService.deleteAssessment(assessmentId);
        } catch (e) {
          print('Error deleting from cloud, but deleted locally: $e');
          // We don't consider this a failure since local deletion worked
        }
      }
      
      return true;
    } catch (e) {
      print('Error deleting assessment: $e');
      return false;
    }
  }
  
  // Sync all local assessments to the cloud
  static Future<bool> syncToCloud() async {
    try {
      // Check if sync is enabled
      if (!await isSyncEnabled()) {
        return false;
      }
      
      // Get all local assessments
      final List<Assessment> localAssessments = await _getFromLocalStorage();
      
      // Get all cloud assessments
      final List<Assessment> cloudAssessments = await SupabaseService.getAssessments();
      
      // Create a map of cloud assessments by ID for easier lookup
      final Map<String, Assessment> cloudMap = {
        for (var assessment in cloudAssessments) assessment.id: assessment
      };
      
      // Track success
      bool allSucceeded = true;
      
      // Push local assessments to cloud
      for (final assessment in localAssessments) {
        final cloudAssessment = cloudMap[assessment.id];
        
        // If the assessment doesn't exist in the cloud or the local version is newer, push it
        if (cloudAssessment == null || 
           (assessment.completedAt != null && 
            cloudAssessment.completedAt != null &&
            assessment.completedAt!.isAfter(cloudAssessment.completedAt!))) {
          try {
            await SupabaseService.saveAssessment(assessment);
          } catch (e) {
            print('Error syncing assessment to cloud: $e');
            allSucceeded = false;
          }
        }
      }
      
      return allSucceeded;
    } catch (e) {
      print('Error syncing to cloud: $e');
      return false;
    }
  }
  
  // Clear all assessments (for testing/debugging)
  static Future<bool> clearAllAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_assessmentsKey);
      
      // If sync is enabled, also clear from cloud
      if (await isSyncEnabled()) {
        try {
          // Note: We don't have a clear all method in SupabaseService,
          // but we could add one if needed
        } catch (e) {
          print('Error clearing assessments from cloud: $e');
        }
      }
      
      return success;
    } catch (e) {
      print('Error clearing assessments: $e');
      return false;
    }
  }
  
  // Helper methods for local storage
  
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