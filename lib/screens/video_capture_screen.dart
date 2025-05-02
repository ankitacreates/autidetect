import 'dart:async';
import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';

class VideoCaptureScreen extends StatefulWidget {
  const VideoCaptureScreen({Key? key}) : super(key: key);

  @override
  State<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  bool _isRecording = false;
  bool _isProcessing = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  void _mockRecordVideo() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    // Mock a recording timer
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });

      // Auto-stop after 10 seconds for demo purposes
      if (_recordingDuration >= 10) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    // Mock processing delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
      });
      
      // Navigate to the next screen - for demo, go to questionnaire
      Navigator.pushNamed(context, AppRoutes.questionnaire);
    });
  }

  void _mockPickVideoFromGallery() {
    setState(() {
      _isProcessing = true;
    });

    // Mock a delay for "selecting" a video
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isProcessing = false;
      });
      
      // Navigate to the next screen - for demo, go to questionnaire
      Navigator.pushNamed(context, AppRoutes.questionnaire);
    });
  }

  void _skipVideoSection() {
    Navigator.pushNamed(context, AppRoutes.questionnaire);
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.recordVideo),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Video Assessment',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Record a short video (1-3 minutes) of your child playing or interacting naturally.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              _buildInstructionsBox(),
              const SizedBox(height: 32),
              _isProcessing
                  ? _buildProcessingState()
                  : _isRecording
                      ? _buildRecordingState()
                      : _buildCaptureOptions(),
              const Spacer(),
              if (!_isRecording)
                TextButton(
                  onPressed: _skipVideoSection,
                  child: Text(
                    'Skip this section',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.instructions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '1. Find a well-lit area with minimal background noise',
          ),
          const SizedBox(height: 8),
          _buildInstructionItem(
            '2. Position the camera to clearly see your child\'s face and body',
          ),
          const SizedBox(height: 8),
          _buildInstructionItem(
            '3. Encourage natural play and interaction',
          ),
          const SizedBox(height: 8),
          _buildInstructionItem(
            '4. Try to capture responses to your voice or gestures',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureOptions() {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.recordVideo,
          backgroundColor: AppColors.primaryDark,
          onPressed: _mockRecordVideo,
          icon: Icons.videocam,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: AppStrings.uploadFromGallery,
          onPressed: _mockPickVideoFromGallery,
          isOutlined: true,
          backgroundColor: AppColors.primaryDark,
          textColor: AppColors.primaryDark,
          icon: Icons.photo_library,
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    final minutes = _recordingDuration ~/ 60;
    final seconds = _recordingDuration % 60;
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.videocam,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recording in progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: AppStrings.stopRecording,
          backgroundColor: Colors.red,
          onPressed: _stopRecording,
          icon: Icons.stop,
        ),
      ],
    );
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.processingVideo,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
} 