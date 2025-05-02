import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/widgets/custom_text_field.dart';
import 'package:autidetect/models/child_profile_model.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({Key? key}) : super(key: key);

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _ethnicityController = TextEditingController();
  
  Gender _selectedGender = Gender.preferNotToSay;
  bool? _familyHistoryOfAutism;
  bool? _jaundiceAtBirth;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _ethnicityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.childProfile),
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
                CustomTextField(
                  label: AppStrings.childName,
                  hintText: 'Enter child\'s name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your child\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.childAge,
                  hintText: 'Enter age in years',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your child\'s age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0 || age > 18) {
                      return 'Please enter a valid age between 1 and 18';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.childGender,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.childEthnicity,
                  hintText: 'Enter ethnicity (optional)',
                  controller: _ethnicityController,
                ),
                const SizedBox(height: 24),
                _buildYesNoQuestion(
                  title: AppStrings.familyHistory,
                  value: _familyHistoryOfAutism,
                  onChanged: (value) {
                    setState(() {
                      _familyHistoryOfAutism = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildYesNoQuestion(
                  title: AppStrings.jaundiceAtBirth,
                  value: _jaundiceAtBirth,
                  onChanged: (value) {
                    setState(() {
                      _jaundiceAtBirth = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: AppStrings.saveProfile,
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

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: Gender.values.map((gender) {
          return RadioListTile<Gender>(
            title: Text(
              _getGenderText(gender),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            value: gender,
            groupValue: _selectedGender,
            activeColor: AppColors.primaryDark,
            onChanged: (Gender? value) {
              if (value != null) {
                setState(() {
                  _selectedGender = value;
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return AppStrings.male;
      case Gender.female:
        return AppStrings.female;
      case Gender.other:
        return AppStrings.otherGender;
      case Gender.preferNotToSay:
        return AppStrings.preferNotToSay;
    }
  }

  Widget _buildYesNoQuestion({
    required String title,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              RadioListTile<bool>(
                title: Text(
                  AppStrings.yes,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                value: true,
                groupValue: value,
                activeColor: AppColors.primaryDark,
                onChanged: onChanged,
              ),
              RadioListTile<bool>(
                title: Text(
                  AppStrings.no,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                value: false,
                groupValue: value,
                activeColor: AppColors.primaryDark,
                onChanged: onChanged,
              ),
              RadioListTile<bool?>(
                title: Text(
                  AppStrings.notSure,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                value: null,
                groupValue: value,
                activeColor: AppColors.primaryDark,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // In a real app, we would save the profile to a database
      // For now, just navigate to the home screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.profileSaved),
          backgroundColor: AppColors.success,
        ),
      );
      
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
    }
  }
} 