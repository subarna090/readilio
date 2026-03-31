import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/session_controller.dart';
import '../../theme/app_theme.dart';
import '../paywall/paywall_screen.dart';
import '../processing/processing_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _lastCapturePath;
  String _guidanceMessage = '';
  bool _flashOn = false;

  final SessionController _sessionCtrl = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionCtrl.startNewCapture();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      setState(() => _guidanceMessage = 'Camera permission required');
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _guidanceMessage = 'No camera found');
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  Future<void> _capture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    // Check free tier limit before capturing
    if (_sessionCtrl.isAtFreeLimit && !_sessionCtrl.isPremium) {
      _showPaywall();
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await _cameraController!.takePicture();
      await _sessionCtrl.addCapturedImage(file.path);
      setState(() {
        _lastCapturePath = file.path;
        _isCapturing = false;
      });
    } catch (e) {
      setState(() {
        _guidanceMessage = 'Capture failed. Try again.';
        _isCapturing = false;
      });
    }
  }

  void _retryLast() {
    _sessionCtrl.retryLastCapture();
    setState(() => _lastCapturePath = null);
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    setState(() => _flashOn = !_flashOn);
    await _cameraController!
        .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
  }

  void _showPaywall() {
    Get.to(() => const PaywallScreen());
  }

  Future<void> _proceed() async {
    if (_sessionCtrl.capturedImagePaths.isEmpty) return;
    Get.to(() => const ProcessingScreen());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  _PageCounter(),
                  IconButton(
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // Guidance overlay
          if (_guidanceMessage.isNotEmpty)
            Positioned(
              bottom: 180,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _guidanceMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomControls(
              lastCapturePath: _lastCapturePath,
              isCapturing: _isCapturing,
              onCapture: _capture,
              onRetry: _retryLast,
              onProceed: _proceed,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Page ${ctrl.capturedImagePaths.length} / ${ctrl.maxPhotos}',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
        ));
  }
}

class _BottomControls extends StatelessWidget {
  final String? lastCapturePath;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onRetry;
  final VoidCallback onProceed;

  const _BottomControls({
    required this.lastCapturePath,
    required this.isCapturing,
    required this.onCapture,
    required this.onRetry,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SessionController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastCapturePath != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Next Page'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail of last captured
              if (lastCapturePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(lastCapturePath!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const SizedBox(width: 56),

              // Main capture button
              GestureDetector(
                onTap: isCapturing ? null : onCapture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCapturing
                        ? Colors.grey
                        : AppColors.primary,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: isCapturing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera_alt,
                          color: Colors.white, size: 32),
                ),
              ),

              // Proceed button
              Obx(() => TextButton(
                    onPressed: ctrl.capturedImagePaths.isNotEmpty
                        ? onProceed
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: ctrl.capturedImagePaths.isNotEmpty
                              ? AppColors.secondary
                              : Colors.grey,
                          size: 32,
                        ),
                        const Text('Done',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
