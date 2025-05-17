import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/services/assessment_storage_service.dart';
import 'package:autidetect/services/export_service.dart';

class ResultsScreen extends StatefulWidget {
  final Assessment assessment;

  const ResultsScreen({
    Key? key,
    required this.assessment,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isSaving = false;
  bool _resultsSaved = false;

  @override
  void initState() {
    super.initState();
    _saveAssessmentResult();
  }

  // Save assessment result to local storage
  Future<void> _saveAssessmentResult() async {
    if (!_resultsSaved) {
      setState(() {
        _isSaving = true;
      });

      try {
        final success = await AssessmentStorageService.saveAssessment(widget.assessment);
        setState(() {
          _resultsSaved = success;
        });
      } catch (e) {
        print('Error saving assessment: $e');
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Share PDF file
  void _shareAssessmentResults() {
    // In a real app, this would share the assessment results
    // For now, we'll just navigate to the resources screen
    Navigator.pushNamed(
      context, 
      AppRoutes.resources,
      arguments: 0, // Educational Content tab
    );
  }

  // Simple date formatter function
  String _formatDate(DateTime? date) {
    date ??= DateTime.now();
    
    // List of month names
    const List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.assessmentResults),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultHeader(),
              const SizedBox(height: 24),
              _buildLikelihoodCard(),
              const SizedBox(height: 24),
              _buildWhatThisMeansSection(),
              const SizedBox(height: 24),
              _buildNextStepsSection(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: 32,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.assessmentResults,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            // Status indicator
            if (_isSaving)
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            else if (_resultsSaved)
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saved',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${AppStrings.assessmentDate}${_formatDate(widget.assessment.completedAt)}',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Assessment Type: ${widget.assessment.type == AssessmentType.toddler ? "Toddler (18-36 months)" : "Child (3-12 years)"}',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLikelihoodCard() {
    final String likelihoodText = _getLikelihoodText();
    final Color likelihoodColor = _getLikelihoodColor();
    final String description = _getLikelihoodDescription();
    final int percentage = widget.assessment.qualityScore ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Assessment',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    likelihoodText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: likelihoodColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: likelihoodColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: likelihoodColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(likelihoodColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailedResults(),
        ],
      ),
    );
  }

  Widget _buildDetailedResults() {
    final responses = widget.assessment.questionnaireResponses ?? [];
    if (responses.isEmpty) return const SizedBox.shrink();

    // Group responses by category
    final Map<String, List<Map<String, dynamic>>> categorizedResponses = {};
    for (var response in responses) {
      final category = response['category'] as String? ?? 'General';
      if (!categorizedResponses.containsKey(category)) {
        categorizedResponses[category] = [];
      }
      categorizedResponses[category]!.add(response);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...categorizedResponses.entries.map((entry) {
          final category = entry.key;
          final categoryResponses = entry.value;
          
          // Calculate category score
          int categoryScore = 0;
          int totalQuestions = categoryResponses.length;
          for (var response in categoryResponses) {
            final score = response['score'] as int? ?? 0;
            categoryScore += score;
          }
          final categoryPercentage = totalQuestions > 0 
              ? (categoryScore / (totalQuestions * 3) * 100).round() 
              : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(categoryPercentage).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$categoryPercentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(categoryPercentage),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: categoryPercentage / 100,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCategoryColor(categoryPercentage),
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 16),
                ...categoryResponses.map((response) {
                  final question = response['question'] as String? ?? '';
                  final answer = response['answer'] as String? ?? '';
                  final score = response['score'] as int? ?? 0;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Response: $answer',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(score).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Score: $score',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(score),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getCategoryColor(int percentage) {
    if (percentage >= 70) return Colors.red;
    if (percentage >= 40) return Colors.orange;
    return Colors.green;
  }

  Widget _buildWhatThisMeansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.whatDoesThisMean,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'These results are based on your responses to the autism screening questionnaire.',
          Icons.info_outline,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'This is not a diagnosis. Only a qualified healthcare professional can diagnose autism.',
          Icons.medical_services_outlined,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Early intervention can significantly improve outcomes for children with autism.',
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryDark,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.nextSteps,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildNextStepCard(
          'Share these results with a healthcare professional',
          'Discuss these screening results with your child\'s pediatrician or a developmental specialist.',
          Icons.share,
          onTap: _shareAssessmentResults,
        ),
        const SizedBox(height: 12),
        _buildNextStepCard(
          'Learn more about developmental milestones',
          'Understand typical childhood development and potential signs of autism.',
          Icons.menu_book,
          onTap: () {
            Navigator.pushNamed(
              context, 
              AppRoutes.resources,
              arguments: 1, // Developmental Milestones tab
            );
          },
        ),
        const SizedBox(height: 12),
        _buildNextStepCard(
          'Schedule a follow-up assessment',
          'Tracking development over time provides more accurate insights.',
          Icons.calendar_today,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.assessmentSelection);
          },
        ),
      ],
    );
  }

  Widget _buildNextStepCard(
    String title,
    String description,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.findSpecialist,
          onPressed: () {
            // In a real app, this would show a map of specialists
            Navigator.pushNamed(
              context, 
              AppRoutes.resources,
              arguments: 0, // Educational Content tab
            );
          },
          isOutlined: true,
          backgroundColor: AppColors.primaryDark,
          textColor: AppColors.primaryDark,
          icon: Icons.location_on,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Back to Home',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
          isOutlined: true,
          backgroundColor: AppColors.primary,
          textColor: AppColors.primary,
          icon: Icons.home,
        ),
      ],
    );
  }

  String _getLikelihoodText() {
    switch (widget.assessment.likelihood) {
      case AutismLikelihood.low:
        return AppStrings.lowLikelihood;
      case AutismLikelihood.moderate:
        return AppStrings.moderateLikelihood;
      case AutismLikelihood.high:
        return AppStrings.highLikelihood;
      case AutismLikelihood.unknown:
      default:
        return 'Inconclusive';
    }
  }

  Color _getLikelihoodColor() {
    switch (widget.assessment.likelihood) {
      case AutismLikelihood.low:
        return Colors.green;
      case AutismLikelihood.moderate:
        return Colors.orange;
      case AutismLikelihood.high:
        return Colors.red;
      case AutismLikelihood.unknown:
      default:
        return Colors.grey;
    }
  }

  String _getLikelihoodDescription() {
    switch (widget.assessment.likelihood) {
      case AutismLikelihood.low:
        return 'Based on your responses, there is a low likelihood of autism-related behaviors. Continue to monitor your child\'s development.';
      case AutismLikelihood.moderate:
        return 'Based on your responses, there is a moderate likelihood of autism-related behaviors. We recommend discussing these results with a healthcare professional.';
      case AutismLikelihood.high:
        return 'Based on your responses, there is a high likelihood of autism-related behaviors. We strongly recommend consulting with a developmental specialist or pediatrician as soon as possible.';
      case AutismLikelihood.unknown:
      default:
        return 'The assessment was inconclusive. This may happen if too few questions were answered or if there were inconsistencies in the responses.';
    }
  }
} 