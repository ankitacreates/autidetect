import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/widgets/custom_card.dart';
import 'package:autidetect/models/user_model.dart';

// User Type Selection Screen following roadmap guidelines:
// - Clear options with both text and visual elements
// - Simple, clean interface with minimal distractions
// - Straightforward choices

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  UserType? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.selectUserType),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.selectUserType,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              _buildUserTypeOption(
                title: AppStrings.parent,
                icon: Icons.family_restroom,
                description: 'You are a parent or guardian of a child',
                userType: UserType.parent,
              ),
              const SizedBox(height: 16),
              _buildUserTypeOption(
                title: AppStrings.caregiver,
                icon: Icons.volunteer_activism,
                description: 'You are a caregiver for a child but not their parent',
                userType: UserType.caregiver,
              ),
              const SizedBox(height: 16),
              _buildUserTypeOption(
                title: AppStrings.healthcareProfessional,
                icon: Icons.medical_services,
                description: 'You are a healthcare provider or specialist',
                userType: UserType.healthcareProfessional,
              ),
              const Spacer(),
              CustomButton(
                text: AppStrings.next,
                backgroundColor: AppColors.primaryDark,
                onPressed: _selectedUserType != null
                    ? () {
                        // First, determine where to navigate based on user type
                        if (_selectedUserType == UserType.healthcareProfessional) {
                          // Healthcare professional goes straight to home
                          Navigator.pushNamed(context, AppRoutes.home);
                        } else {
                          // Parents and caregivers go to profile setup
                          Navigator.pushNamed(
                            context,
                            AppRoutes.parentProfile,
                            arguments: _selectedUserType,
                          );
                        }
                      }
                    : null,
                icon: Icons.arrow_forward,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeOption({
    required String title,
    required IconData icon,
    required String description,
    required UserType userType,
  }) {
    final isSelected = _selectedUserType == userType;
    
    return CustomCard(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      backgroundColor: isSelected 
          ? AppColors.primaryLight.withOpacity(0.1) 
          : Colors.white,
      elevation: 2,
      child: Row(
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
    );
  }
} 