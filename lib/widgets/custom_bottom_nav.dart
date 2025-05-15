import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/services/supabase_service.dart';
import 'package:autidetect/models/user_model.dart' as app_models;

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textLight,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) => _onNavItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Assessments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined),
          activeIcon: Icon(Icons.insert_chart),
          label: 'Results',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<void> _onNavItemTapped(BuildContext context, int index) async {
    // Don't navigate if we're already on the selected page
    if (index == currentIndex) return;

    // Clear navigation stack and go to the selected page
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.home,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.assessmentSelection,
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.assessmentHistory,
          (route) => false,
        );
        break;
      case 3:
        // Get current user to determine user type
        final currentUser = await SupabaseService.getCurrentUser();
        // Use parent as default if no user type is available
        final userType = currentUser?.userType ?? app_models.UserType.parent;
        
        Navigator.pushNamedAndRemoveUntil(
          context, 
          AppRoutes.parentProfile,
          (route) => false,
          arguments: userType,
        );
        break;
    }
  }
} 