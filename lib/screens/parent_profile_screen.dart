import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/widgets/custom_text_field.dart';
import 'package:autidetect/models/parent_profile_model.dart';
import 'package:autidetect/models/user_model.dart';

class ParentProfileScreen extends StatefulWidget {
  final UserType userType;
  
  const ParentProfileScreen({
    Key? key, 
    required this.userType,
  }) : super(key: key);

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.userType == UserType.parent
        ? AppStrings.parentProfile
        : AppStrings.caregiverProfile;
        
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accent2,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Photo upload logic would go here
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: AppStrings.firstName,
                        hintText: 'Enter your first name',
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: AppStrings.lastName,
                        hintText: 'Enter your last name',
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.email,
                  hintText: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    final bool emailValid = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(value);
                    if (!emailValid) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.phoneNumber,
                  hintText: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final bool phoneValid = RegExp(
                        r'^\+?[0-9]{10,15}$',
                      ).hasMatch(value);
                      if (!phoneValid) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.address,
                  hintText: 'Enter your address (optional)',
                  controller: _addressController,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.yourRole,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.userType == UserType.parent
                            ? Icons.family_restroom
                            : Icons.volunteer_activism,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.userType == UserType.parent
                            ? AppStrings.parent
                            : AppStrings.caregiver,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: AppStrings.saveParentProfile,
                  backgroundColor: AppColors.primaryDark,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // In a real app, we would save the profile to a database
      final profile = ParentProfile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}', // Generate a unique ID
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        userType: widget.userType,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        hasCompletedOnboarding: true,
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.parentProfileSaved),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Navigate to the child profile screen
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamed(context, AppRoutes.childProfile);
      });
    }
  }
} 