import 'package:flutter/material.dart';

enum ResponseType {
  frequency, // mostly, sometimes, rarely, never
  yesNo, // yes, no, not sure
  rating, // 1-5 scale
}

enum QuestionnaireType {
  toddler,
  child,
}

class AssessmentQuestion {
  final String id;
  final String question;
  final String? description;
  final ResponseType responseType;
  final int weight; // Weight for scoring (1-3, where 3 is most significant)
  final QuestionnaireType type;

  const AssessmentQuestion({
    required this.id,
    required this.question,
    this.description,
    required this.responseType,
    required this.weight,
    required this.type,
  });
}

class QuestionResponse {
  final String questionId;
  final int responseValue; // 0-3 for frequency, 0-1 for yes/no, 1-5 for rating
  final String? notes;

  QuestionResponse({
    required this.questionId,
    required this.responseValue,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'responseValue': responseValue,
      'notes': notes,
    };
  }

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['questionId'],
      responseValue: json['responseValue'],
      notes: json['notes'],
    );
  }
}

// Sample questions based on validated autism screening tools
// Simplified for demonstration purposes
class AssessmentQuestions {
  static const List<AssessmentQuestion> toddlerQuestions = [
    AssessmentQuestion(
      id: 't1',
      question: 'Does your child look at you when you call their name?',
      description: 'Observe how consistently your child responds to their name being called.',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't2',
      question: 'How easy is it for you to get eye contact with your child?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't3',
      question: 'Does your child point to indicate interest in something?',
      description: 'For example, pointing to interesting objects or events to share interest, not just to get help.',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't4',
      question: 'Does your child pretend? For example, taking care of dolls or talking on a toy phone?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't5',
      question: "Does your child follow where you're looking?",
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't6',
      question: 'If you or someone else in the family is visibly upset, does your child show signs of concern?',
      description: 'For example, looking sad or asking "okay?"',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't7',
      question: 'Does your child smile back if someone smiles at them?',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't8',
      question: 'Does your child try to copy what you do?',
      description: 'For example, waving bye-bye, clapping, or making funny sounds.',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't9',
      question: 'Does your child respond when you call their name?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.toddler,
    ),
    AssessmentQuestion(
      id: 't10',
      question: 'Does your child become upset by everyday sounds?',
      description: 'For example, vacuum cleaner, hair dryer, or loud noises.',
      responseType: ResponseType.frequency,
      weight: 1,
      type: QuestionnaireType.toddler,
    ),
  ];

  static const List<AssessmentQuestion> childQuestions = [
    AssessmentQuestion(
      id: 'c1',
      question: 'Does your child have difficulty making friends with other children their age?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c2',
      question: 'Does your child have difficulty maintaining back-and-forth conversation?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c3',
      question: 'Does your child have repetitive behaviors or routines that seem unnecessary?',
      description: 'For example, lining up toys or objects in a specific way repeatedly.',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c4',
      question: 'Does your child have unusually narrow or intense interests?',
      description: 'For example, knowing an exceptional amount about specific topics or being overly attached to unusual objects.',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c5',
      question: 'Does your child have difficulty understanding other people\'s feelings?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c6',
      question: 'Does your child have unusual or repetitive hand or body movements?',
      description: 'For example, hand-flapping, finger-flicking, or rocking.',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c7',
      question: 'Does your child have difficulty adapting to changes in routine?',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c8',
      question: 'Is your child overly sensitive to sensory input?',
      description: 'For example, bothered by certain sounds, textures, or lights that don\'t bother other children.',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c9',
      question: 'Does your child have difficulty maintaining eye contact during conversation?',
      responseType: ResponseType.frequency,
      weight: 3,
      type: QuestionnaireType.child,
    ),
    AssessmentQuestion(
      id: 'c10',
      question: 'Does your child interpret language very literally?',
      description: 'For example, confused by phrases like "break a leg" or "it\'s raining cats and dogs."',
      responseType: ResponseType.frequency,
      weight: 2,
      type: QuestionnaireType.child,
    ),
  ];

  // Get questions based on assessment type
  static List<AssessmentQuestion> getQuestions(QuestionnaireType type) {
    return type == QuestionnaireType.toddler ? toddlerQuestions : childQuestions;
  }

  // Calculate risk level based on responses
  static Map<String, dynamic> calculateRiskScore(List<QuestionResponse> responses, QuestionnaireType type) {
    final questions = getQuestions(type);
    int totalScore = 0;
    int maxPossibleScore = 0;
    
    // Calculate weighted score
    for (final response in responses) {
      final question = questions.firstWhere((q) => q.id == response.questionId);
      
      // For frequency questions: 3 = never, 2 = rarely, 1 = sometimes, 0 = mostly (reversed for scoring)
      // Higher score means higher likelihood of autism traits
      if (question.responseType == ResponseType.frequency) {
        totalScore += (3 - response.responseValue) * question.weight;
        maxPossibleScore += 3 * question.weight; // Max possible score for this question
      }
    }
    
    // Convert to percentage
    final percentageScore = (totalScore / maxPossibleScore) * 100;
    
    // Determine risk level (these thresholds are simplified for demo purposes)
    final riskLevel = percentageScore < 30 
        ? 'low' 
        : percentageScore < 60 
            ? 'moderate' 
            : 'high';
    
    return {
      'score': totalScore,
      'maxScore': maxPossibleScore,
      'percentage': percentageScore.round(),
      'riskLevel': riskLevel,
    };
  }
} 