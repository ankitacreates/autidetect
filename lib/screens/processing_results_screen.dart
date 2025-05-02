import 'dart:async';
import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/models/assessment_model.dart';

class ProcessingResultsScreen extends StatefulWidget {
  final Assessment assessment;

  const ProcessingResultsScreen({
    Key? key,
    required this.assessment,
  }) : super(key: key);

  @override
  State<ProcessingResultsScreen> createState() => _ProcessingResultsScreenState();
}

class _ProcessingResultsScreenState extends State<ProcessingResultsScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _progressPercentage = 0;
  String _statusText = 'Analyzing responses...';
  Timer? _fakeProcessingTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {
        _progressPercentage = (_progressAnimation.value * 100).floor();
      });
    });

    _animationController.forward();

    // Simulate processing steps
    _fakeProcessingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == 1) {
        setState(() {
          _statusText = 'Analyzing video data...';
        });
      } else if (timer.tick == 2) {
        setState(() {
          _statusText = 'Calculating results...';
        });
      } else if (timer.tick == 3) {
        setState(() {
          _statusText = 'Generating report...';
        });
      } else if (timer.tick == 4) {
        setState(() {
          _statusText = 'Finalizing assessment...';
        });
      } else if (timer.tick == 5) {
        _fakeProcessingTimer?.cancel();
        // Navigate to results screen
        Navigator.pushReplacementNamed(
          context, 
          AppRoutes.results,
          arguments: widget.assessment,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fakeProcessingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 8,
                            backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Text(
                          '$_progressPercentage%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Processing Your Assessment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryDark,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our AI algorithms are analyzing your responses to provide the most accurate assessment possible.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 