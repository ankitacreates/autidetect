import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:autidetect/widgets/custom_card.dart';
import 'package:autidetect/widgets/custom_bottom_nav.dart';
import 'package:autidetect/models/user_model.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:autidetect/models/child_profile_model.dart';
import 'package:autidetect/services/assessment_storage_service.dart';
import 'package:intl/intl.dart';
import 'package:autidetect/services/supabase_service.dart';

// Home Screen following roadmap guidelines:
// - Clean layout with clearly delineated sections
// - Limited elements per screen to reduce distraction
// - Clear text labels accompanying all icons
// - Soft, muted color palette

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  bool _isLoading = true;
  List<ChildProfile> _childProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await SupabaseService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
      
      if (user != null && user.childProfileIds.isNotEmpty) {
        final childProfiles = await SupabaseService.getChildProfiles(user.id);
        setState(() {
          _childProfiles = childProfiles;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 28,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: 8),
            Text(AppStrings.appName),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'settings') {
                Navigator.pushNamed(context, AppRoutes.settings);
              } else if (value == 'logout') {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true) {
                  // Perform logout
                  await SupabaseService.signOut();
                  // Navigate to welcome screen
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    AppRoutes.welcome,
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: AppColors.primaryDark),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.primaryDark),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildActionsSection(context),
                    const SizedBox(height: 24),
                    _buildRecentResultsSection(context),
                    const SizedBox(height: 24),
                    _buildResourcesSection(context),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser != null 
              ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
              : 'Guest User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _childProfiles.isNotEmpty
            ? CustomCard(
                backgroundColor: Colors.white,
                elevation: 2,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.accent2,
                      child: Text(
                        _getInitials(_childProfiles[0].name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _childProfiles[0].name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Age: ${_childProfiles[0].age} years',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        // Navigate to child profile
                        Navigator.pushNamed(context, AppRoutes.childProfile);
                      },
                    ),
                  ],
                ),
              )
            : CustomCard(
                backgroundColor: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No child profiles yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        text: 'Add Child Profile',
                        backgroundColor: AppColors.primaryDark,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.childProfile);
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.length == 1) {
      return nameParts[0][0];
    }
    
    return '';
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          elevation: 2,
          backgroundColor: Colors.white,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.assessmentSelection);
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start New Assessment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete a new autism screening',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          elevation: 2,
          backgroundColor: Colors.white,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.chat);
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent2.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.accent2,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AutiHelp Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Chat with our AI assistant',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          elevation: 2,
          backgroundColor: Colors.white,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.assessmentHistory);
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent2.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: AppColors.accent2,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Results',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review past assessment results',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          elevation: 2,
          backgroundColor: Colors.white,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.parentProfile, arguments: UserType.parent);
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Edit your personal information',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentResultsSection(BuildContext context) {
    return FutureBuilder<List<Assessment>>(
      future: AssessmentStorageService.getAssessments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final assessments = snapshot.data ?? [];
        
        // Sort by date (newest first)
        assessments.sort((a, b) {
          final aDate = a.completedAt ?? a.createdAt;
          final bDate = b.completedAt ?? b.createdAt;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });
        
        // Take only completed assessments
        final completedAssessments = assessments
            .where((a) => a.status == AssessmentStatus.completed)
            .toList();
            
        // Show only the 3 most recent
        final recentAssessments = completedAssessments.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (completedAssessments.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.assessmentHistory);
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (recentAssessments.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No assessments completed yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Start Your First Assessment',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.assessmentSelection);
                      },
                      height: 40,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentAssessments.length,
                itemBuilder: (context, index) {
                  final assessment = recentAssessments[index];
                  return _buildRecentAssessmentItem(context, assessment);
                },
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildRecentAssessmentItem(BuildContext context, Assessment assessment) {
    final date = assessment.completedAt ?? assessment.createdAt;
    final formattedDate = date != null 
        ? DateFormat('MMM d, yyyy').format(date) 
        : 'N/A';
    
    Color statusColor;
    switch (assessment.likelihood) {
      case AutismLikelihood.low:
        statusColor = Colors.green;
        break;
      case AutismLikelihood.moderate:
        statusColor = Colors.orange;
        break;
      case AutismLikelihood.high:
        statusColor = Colors.red;
        break;
      case AutismLikelihood.unknown:
      default:
        statusColor = Colors.grey;
    }
    
    String likelihoodText;
    switch (assessment.likelihood) {
      case AutismLikelihood.low:
        likelihoodText = AppStrings.lowLikelihood;
        break;
      case AutismLikelihood.moderate:
        likelihoodText = AppStrings.moderateLikelihood;
        break;
      case AutismLikelihood.high:
        likelihoodText = AppStrings.highLikelihood;
        break;
      case AutismLikelihood.unknown:
      default:
        likelihoodText = 'Inconclusive';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.results,
            arguments: assessment,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${assessment.qualityScore ?? 0}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.type == AssessmentType.toddler
                          ? 'Toddler Assessment'
                          : 'Child Assessment',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  likelihoodText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resources',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomCard(
                backgroundColor: Colors.white,
                elevation: 2,
                onTap: () {
                  // Navigate to educational content
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.resources,
                    arguments: 0, // Educational Content tab
                  ).then((_) {
                    setState(() {
                      // Refresh data when returning from Resources screen
                    });
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 32,
                      color: AppColors.accent1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Educational Content',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                backgroundColor: Colors.white,
                elevation: 2,
                onTap: () {
                  // Navigate to developmental milestones
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.resources,
                    arguments: 1, // Developmental Milestones tab
                  ).then((_) {
                    setState(() {
                      // Refresh data when returning from Resources screen
                    });
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care,
                      size: 32,
                      color: AppColors.accent2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Developmental Milestones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomCard(
                backgroundColor: Colors.white,
                elevation: 2,
                onTap: () {
                  // Navigate to local services
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.resources,
                    arguments: 2, // Local Services tab
                  ).then((_) {
                    setState(() {
                      // Refresh data when returning from Resources screen
                    });
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 32,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Local Services',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                backgroundColor: Colors.white,
                elevation: 2,
                onTap: () {
                  // Navigate to FAQ
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.resources,
                    arguments: 3, // FAQ tab
                  ).then((_) {
                    setState(() {
                      // Refresh data when returning from Resources screen
                    });
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 