import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/services/assessment_storage_service.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AssessmentHistoryScreen extends StatefulWidget {
  const AssessmentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentHistoryScreen> createState() => _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  List<Assessment> _assessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final assessments = await AssessmentStorageService.getAssessments();
      setState(() {
        _assessments = assessments;
      });
    } catch (e) {
      print('Error loading assessments: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load assessment history'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _viewAssessmentDetails(Assessment assessment) {
    Navigator.pushNamed(
      context,
      AppRoutes.results,
      arguments: assessment,
    );
  }

  Future<void> _deleteAssessment(String id) async {
    try {
      final success = await AssessmentStorageService.deleteAssessment(id);
      if (success) {
        setState(() {
          _assessments.removeWhere((assessment) => assessment.id == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting assessment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete assessment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Color _getLikelihoodColor(AutismLikelihood likelihood) {
    switch (likelihood) {
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

  String _getLikelihoodText(AutismLikelihood likelihood) {
    switch (likelihood) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assessment History'),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssessments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _assessments.isEmpty
              ? _buildEmptyState()
              : _buildAssessmentList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              'No assessment results yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Complete an assessment to see your results here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Start New Assessment',
              backgroundColor: AppColors.primaryDark,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.assessmentSelection);
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentList() {
    // Sort assessments by date (newest first)
    _assessments.sort((a, b) {
      final aDate = a.completedAt ?? a.createdAt;
      final bDate = b.completedAt ?? b.createdAt;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return RefreshIndicator(
      onRefresh: _loadAssessments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _assessments.length,
        itemBuilder: (context, index) {
          final assessment = _assessments[index];
          return _buildAssessmentCard(assessment);
        },
      ),
    );
  }

  Widget _buildAssessmentCard(Assessment assessment) {
    final completedDate = assessment.completedAt ?? assessment.createdAt;
    final status = assessment.status;
    final type = assessment.type;
    final likelihood = assessment.likelihood;
    final score = assessment.qualityScore ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewAssessmentDetails(assessment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      type == AssessmentType.toddler
                          ? 'Toddler Assessment'
                          : 'Child Assessment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status == AssessmentStatus.completed
                          ? Colors.green.withOpacity(0.1)
                          : Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status == AssessmentStatus.completed
                          ? 'Completed'
                          : status == AssessmentStatus.scheduled
                              ? 'Scheduled'
                              : status == AssessmentStatus.inProgress
                                  ? 'In Progress'
                                  : 'Not Started',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: status == AssessmentStatus.completed
                            ? Colors.green
                            : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Date: ${_formatDate(completedDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (status == AssessmentStatus.completed) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getLikelihoodColor(likelihood),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Result: ${_getLikelihoodText(likelihood)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getLikelihoodColor(likelihood),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Score: $score%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _viewAssessmentDetails(assessment),
                    icon: const Icon(
                      Icons.visibility,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'View Details',
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Show confirmation dialog before deletion
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Assessment'),
                          content: const Text(
                            'Are you sure you want to delete this assessment? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteAssessment(assessment.id);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 