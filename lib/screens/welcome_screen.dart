import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Welcome Screen following roadmap guidelines:
// - Simple, clean welcome screen with new blue/lavender color palette
// - Clear registration options
// - Minimal distractions

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              // Logo and app name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      child: SvgPicture.asset(
                        'assets/images/autidetect_logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Action buttons
              CustomButton(
                text: AppStrings.getStarted,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.userTypeSelection);
                },
                icon: Icons.arrow_forward,
                backgroundColor: AppColors.primaryDark,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 