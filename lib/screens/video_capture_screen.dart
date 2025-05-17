import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/widgets/custom_button.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCaptureScreen extends StatefulWidget {
  const VideoCaptureScreen({Key? key}) : super(key: key);

  @override
  State<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  List<CameraDescription>? _cameras;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
    
    if (_hasPermission) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('No cameras available');
        return;
      }

      _controller = CameraController(
        _cameras![0], // Use the first camera (usually the back camera)
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile video = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Process the video file
      print('Video saved to: ${video.path}');
      
      // Navigate to the next screen
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.questionnaire);
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 64,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera permission is required',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Grant Permission',
                backgroundColor: AppColors.primaryDark,
                onPressed: _checkPermissions,
                icon: Icons.camera_alt,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.recordVideo),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (!_isRecording)
                    CustomButton(
                      text: 'Start Recording',
                      backgroundColor: AppColors.primaryDark,
                      onPressed: _startRecording,
                      icon: Icons.videocam,
                    )
                  else
                    CustomButton(
                      text: 'Stop Recording',
                      backgroundColor: Colors.red,
                      onPressed: _stopRecording,
                      icon: Icons.stop,
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.questionnaire),
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
          ],
        ),
      ),
    );
  }
} 