import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/widgets/custom_card.dart';
import 'package:autidetect/widgets/custom_bottom_nav.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/screens/schedule_assessment_screen.dart';

// Assessment Selection Screen following roadmap guidelines:
// - Clear visual indicators showing estimated completion time
// - Age-appropriate assessment options
// - Simple, distraction-free interface

class AssessmentSelectionScreen extends StatefulWidget {
  const AssessmentSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentSelectionScreen> createState() => _AssessmentSelectionScreenState();
}

class _AssessmentSelectionScreenState extends State<AssessmentSelectionScreen> {
  AssessmentType? _selectedAssessmentType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.selectAssessment),
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
                AppStrings.selectAssessment,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the assessment that is appropriate for your child\'s age.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildAssessmentOption(
                title: AppStrings.toddlerAssessment,
                icon: Icons.child_care,
                duration: '20-25',
                description: 'For children between 18 months and 3 years',
                assessmentType: AssessmentType.toddler,
              ),
              const SizedBox(height: 16),
              _buildAssessmentOption(
                title: AppStrings.childAssessment,
                icon: Icons.face,
                duration: '25-30',
                description: 'For children between 3 and 12 years',
                assessmentType: AssessmentType.child,
              ),
              const SizedBox(height: 16),
              _buildAssessmentOption(
                title: 'Teen Assessment',
                icon: Icons.person,
                duration: '30-35',
                description: 'For teenagers between 13 and 19 years',
                assessmentType: AssessmentType.teen,
              ),
              const Spacer(),
              CustomButton(
                text: AppStrings.next,
                backgroundColor: AppColors.primaryDark,
                onPressed: _selectedAssessmentType != null
                    ? () {
                        // Here we would save the assessment type
                        // For now, just navigate to the next screen
                        Navigator.pushNamed(
                          context, 
                          AppRoutes.assessmentInstructions,
                          arguments: _selectedAssessmentType,
                        );
                      }
                    : null,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: AppStrings.scheduleForLater,
                onPressed: _selectedAssessmentType != null
                    ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleAssessmentScreen(
                              assessmentType: _selectedAssessmentType!,
                            ),
                          ),
                        );
                        if (result == true) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                isOutlined: true,
                backgroundColor: AppColors.primaryDark,
                textColor: AppColors.primaryDark, 
                icon: Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildAssessmentOption({
    required String title,
    required IconData icon,
    required String duration,
    required String description,
    required AssessmentType assessmentType,
  }) {
    final isSelected = _selectedAssessmentType == assessmentType;
    
    return CustomCard(
      onTap: () {
        setState(() {
          _selectedAssessmentType = assessmentType;
        });
      },
      backgroundColor: isSelected 
          ? AppColors.primaryLight.withOpacity(0.1) 
          : Colors.white,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryDark 
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent1.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${AppStrings.estimatedTime}$duration${AppStrings.minutes}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 