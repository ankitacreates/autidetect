import 'dart:math';
import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/models/questionnaire_model.dart';
import 'package:autidetect/models/assessment_model.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  // For demo purposes, we'll use toddler questions by default
  // In a real app, this would be determined by the selected assessment type
  final QuestionnaireType _questionnaireType = QuestionnaireType.toddler;
  late List<AssessmentQuestion> _questions;
  int _currentQuestionIndex = 0;
  final List<QuestionResponse> _responses = [];
  bool _isLastQuestion = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _questions = AssessmentQuestions.getQuestions(_questionnaireType);
    _updateIsLastQuestion();
  }

  void _updateIsLastQuestion() {
    setState(() {
      _isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    });
  }

  void _submitResponse(int responseValue) {
    final questionId = _questions[_currentQuestionIndex].id;
    
    // Check if we already have a response for this question
    final existingResponseIndex = _responses.indexWhere(
      (response) => response.questionId == questionId
    );
    
    // Create the response
    final response = QuestionResponse(
      questionId: questionId,
      responseValue: responseValue,
    );
    
    // Add or update the response
    if (existingResponseIndex != -1) {
      setState(() {
        _responses[existingResponseIndex] = response;
      });
    } else {
      setState(() {
        _responses.add(response);
      });
    }
    
    if (_isLastQuestion) {
      _completeQuestionnaire();
    } else {
      _goToNextQuestion();
    }
  }

  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _updateIsLastQuestion();
    });
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _updateIsLastQuestion();
      });
    }
  }

  void _skipQuestion() {
    if (_isLastQuestion) {
      _completeQuestionnaire();
    } else {
      _goToNextQuestion();
    }
  }

  // Generate a simple random ID (in real app, use UUID)
  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        12, (_) => chars.codeUnitAt(_random.nextInt(chars.length))
      )
    );
  }

  void _completeQuestionnaire() {
    // In a real app, this would save the assessment data to storage
    // For demo, we'll just calculate the risk score and navigate to results
    final riskData = AssessmentQuestions.calculateRiskScore(
      _responses, 
      _questionnaireType
    );
    
    // Create a mock assessment result with enhanced response data
    final enhancedResponses = _responses.map((response) {
      final question = _questions.firstWhere((q) => q.id == response.questionId);
      return {
        'questionId': response.questionId,
        'question': question.question,
        'category': _getCategoryForQuestion(question),
        'responseValue': response.responseValue,
        'score': (3 - response.responseValue) * question.weight, // Convert response to score
        'answer': _getAnswerText(response.responseValue),
      };
    }).toList();
    
    final assessment = Assessment(
      id: _generateRandomId(),
      childProfileId: 'child1', // In a real app, use the actual child ID
      type: _questionnaireType == QuestionnaireType.toddler 
          ? AssessmentType.toddler 
          : AssessmentType.child,
      status: AssessmentStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      likelihood: _getLikelihoodFromRiskLevel(riskData['riskLevel']),
      qualityScore: riskData['percentage'],
      questionnaireResponses: enhancedResponses,
    );
    
    // Navigate to processing screen
    Navigator.pushNamed(
      context, 
      AppRoutes.processingResults,
      arguments: assessment,
    );
  }

  String _getCategoryForQuestion(AssessmentQuestion question) {
    // Group questions into categories based on their content
    if (question.question.toLowerCase().contains('eye contact') ||
        question.question.toLowerCase().contains('look at you') ||
        question.question.toLowerCase().contains('smile')) {
      return 'Social Communication';
    } else if (question.question.toLowerCase().contains('point') ||
        question.question.toLowerCase().contains('pretend') ||
        question.question.toLowerCase().contains('copy')) {
      return 'Play & Interaction';
    } else if (question.question.toLowerCase().contains('upset') ||
        question.question.toLowerCase().contains('concern') ||
        question.question.toLowerCase().contains('feelings')) {
      return 'Emotional Response';
    } else if (question.question.toLowerCase().contains('sound') ||
        question.question.toLowerCase().contains('noise')) {
      return 'Sensory Processing';
    } else {
      return 'General Development';
    }
  }

  String _getAnswerText(int responseValue) {
    switch (responseValue) {
      case 0:
        return AppStrings.mostly;
      case 1:
        return AppStrings.sometimes;
      case 2:
        return AppStrings.rarely;
      case 3:
        return AppStrings.never;
      default:
        return 'Not answered';
    }
  }

  AutismLikelihood _getLikelihoodFromRiskLevel(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return AutismLikelihood.low;
      case 'moderate':
        return AutismLikelihood.moderate;
      case 'high':
        return AutismLikelihood.high;
      default:
        return AutismLikelihood.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Assessment Questionnaire'),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              _buildQuestion(currentQuestion),
              const Spacer(),
              _buildResponseOptions(currentQuestion),
              const SizedBox(height: 24),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppStrings.question} ${_currentQuestionIndex + 1} ${AppStrings.of} ${_questions.length}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${((_currentQuestionIndex + 1) / _questions.length * 100).round()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildQuestion(AssessmentQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        if (question.description != null) ...[
          const SizedBox(height: 8),
          Text(
            question.description!,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResponseOptions(AssessmentQuestion question) {
    // For this demo, we only handle frequency response type
    if (question.responseType == ResponseType.frequency) {
      return Column(
        children: [
          _buildFrequencyOption(AppStrings.mostly, 0),
          const SizedBox(height: 12),
          _buildFrequencyOption(AppStrings.sometimes, 1),
          const SizedBox(height: 12),
          _buildFrequencyOption(AppStrings.rarely, 2),
          const SizedBox(height: 12),
          _buildFrequencyOption(AppStrings.never, 3),
        ],
      );
    }
    
    // Additional response types would be handled here
    return Container();
  }

  Widget _buildFrequencyOption(String text, int value) {
    // Check if this option is selected for the current question
    final questionId = _questions[_currentQuestionIndex].id;
    final existingResponse = _responses.firstWhere(
      (response) => response.questionId == questionId,
      orElse: () => QuestionResponse(questionId: '', responseValue: -1),
    );
    
    final isSelected = existingResponse.responseValue == value;
    
    return InkWell(
      onTap: () => _submitResponse(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryDark 
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryDark,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: AppStrings.back,
            onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
            isOutlined: true,
            backgroundColor: AppColors.primaryDark,
            textColor: AppColors.primaryDark,
            icon: Icons.arrow_back,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _isLastQuestion ? 'Finish' : AppStrings.skipQuestion,
            backgroundColor: AppColors.primaryDark,
            onPressed: _skipQuestion,
            icon: _isLastQuestion ? Icons.check : Icons.skip_next,
          ),
        ),
      ],
    );
  }
} 