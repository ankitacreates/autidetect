import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/screens/schedule_assessment_screen.dart';

class AssessmentInstructionsScreen extends StatefulWidget {
  final AssessmentType assessmentType;

  const AssessmentInstructionsScreen({
    Key? key,
    required this.assessmentType,
  }) : super(key: key);

  @override
  State<AssessmentInstructionsScreen> createState() => _AssessmentInstructionsScreenState();
}

class _AssessmentInstructionsScreenState extends State<AssessmentInstructionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.assessmentInstructions),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.assessmentInstructions,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please follow these guidelines for the best results:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              _buildInstructionItem(
                icon: Icons.volume_off_outlined,
                text: AppStrings.findQuietPlace,
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                icon: Icons.child_friendly,
                text: AppStrings.ensureChildComfortable,
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                icon: Icons.assignment,
                text: AppStrings.followPrompts,
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                icon: Icons.pause_circle_outline,
                text: AppStrings.canPauseAnytime,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.accent1,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        'This assessment includes both video recording and questionnaire sections. You can complete them in any order.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: AppStrings.beginAssessment,
                backgroundColor: AppColors.primaryDark,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.videoCapture);
                },
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: AppStrings.scheduleForLater,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleAssessmentScreen(
                        assessmentType: widget.assessmentType,
                      ),
                    ),
                  );
                  if (result == true) {
                    Navigator.pop(context);
                  }
                },
                isOutlined: true,
                backgroundColor: AppColors.primaryDark,
                textColor: AppColors.primaryDark,
                icon: Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
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
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
} 