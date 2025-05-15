import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/widgets/custom_bottom_nav.dart';
import 'package:autidetect/services/assessment_storage_service.dart';
import 'package:autidetect/widgets/custom_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  bool _isSyncEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final isSyncEnabled = await AssessmentStorageService.isSyncEnabled();
      setState(() {
        _isSyncEnabled = isSyncEnabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.settings),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStorageSection(),
                    const SizedBox(height: 24),
                    _buildAccountSection(),
                    const SizedBox(height: 24),
                    _buildAppearanceSection(),
                    const SizedBox(height: 24),
                    _buildSupportSection(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Storage & Sync',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          backgroundColor: Colors.white,
          elevation: 2,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Cloud Sync'),
                subtitle: Text(
                  _isSyncEnabled
                      ? 'Assessment results are stored both locally and in the cloud'
                      : 'Assessment results are stored on this device only',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isSyncEnabled,
                activeColor: AppColors.primaryDark,
                onChanged: (value) async {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  try {
                    await AssessmentStorageService.setSyncEnabled(value);
                    
                    if (value) {
                      // If enabling sync, try to sync existing data
                      await AssessmentStorageService.syncToCloud();
                    }
                    
                    setState(() {
                      _isSyncEnabled = value;
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value 
                              ? 'Cloud sync enabled. Your data will now be backed up.'
                              : 'Cloud sync disabled. Data will only be stored on this device.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    print('Error changing sync settings: $e');
                    setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Manual Sync Now'),
                subtitle: const Text('Push all local assessment data to the cloud'),
                trailing: const Icon(Icons.sync, color: AppColors.primaryDark),
                enabled: _isSyncEnabled,
                onTap: _isSyncEnabled ? () async {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  try {
                    final success = await AssessmentStorageService.syncToCloud();
                    
                    setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Sync completed successfully'
                              : 'Sync completed with some errors',
                        ),
                        backgroundColor: success ? AppColors.success : Colors.orange,
                      ),
                    );
                  } catch (e) {
                    print('Error during manual sync: $e');
                    setState(() {
                      _isLoading = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          backgroundColor: Colors.white,
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.primaryDark),
                title: const Text('Your Profile'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to profile
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.password, color: AppColors.primaryDark),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to change password
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appearance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          backgroundColor: Colors.white,
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryDark),
                title: const Text('Theme'),
                subtitle: const Text('Light'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open theme selector
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language, color: AppColors.primaryDark),
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open language selector
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          backgroundColor: Colors.white,
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline, color: AppColors.primaryDark),
                title: const Text('Help Center'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to help center
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryDark),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open privacy policy
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.contact_support_outlined, color: AppColors.primaryDark),
                title: const Text('Contact Us'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open contact form
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 