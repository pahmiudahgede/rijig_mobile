import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/features/auth/presentation/screen/collector/controller/identity_facedetec_controller.dart';

class FaceDetectionView extends StatefulWidget {
  const FaceDetectionView({super.key});

  @override
  State<FaceDetectionView> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<FaceDetectionView>
    with TickerProviderStateMixin {
  late FaceDetectionController _controller;
  late AnimationController _circleAnimationController;
  late AnimationController _successAnimationController;
  late AnimationController _rotatingCircleController;
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _rotatingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = FaceDetectionController();

    _circleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _circleScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _circleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotatingCircleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotatingCircleController);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _controller.initializeTflite();

      await _controller.loadReferenceFaceFromAssets(
        'assets/image/reference_face.jpg',
      );

      await _controller.initializeCamera();

      _controller.addListener(_onControllerStateChanged);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _onControllerStateChanged() {
    if (_controller.shouldShowCircleAnimation &&
        !_rotatingCircleController.isAnimating) {
      _rotatingCircleController.repeat();
      _circleAnimationController.repeat(reverse: true);
    }

    if (_controller.shouldShowSuccessAnimation) {
      _successAnimationController.forward();
      _showSuccessDialog();
    }

    if (_controller.currentState == VerificationState.positioning) {
      _rotatingCircleController.stop();
      _circleAnimationController.stop();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _successScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _successScaleAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Wajah Berhasil Diverifikasi!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tingkat kemiripan: ${(_controller.lastSimilarityScore * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _controller.reset();
                    _successAnimationController.reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Face Verification'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        body: Consumer<FaceDetectionController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                _buildMainContent(controller),

                if (!controller.isCameraInitialized ||
                    !controller.isTfliteInitialized)
                  _buildLoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(FaceDetectionController controller) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(child: _buildCircularCameraPreview(controller)),
        ),

        Expanded(flex: 1, child: _buildStatusSection(controller)),
      ],
    );
  }

  Widget _buildCircularCameraPreview(FaceDetectionController controller) {
    final screenSize = MediaQuery.of(context).size;
    final circleSize = screenSize.width * 0.7;

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _getCircleColor(controller), width: 4),
        boxShadow: [
          BoxShadow(
            color: _getCircleColor(controller).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _circleScaleAnimation,
          _rotatingAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale:
                controller.shouldShowCircleAnimation
                    ? _circleScaleAnimation.value
                    : 1.0,
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: _buildCameraPreviewContent(controller),
                  ),
                ),

                if (controller.shouldShowCircleAnimation)
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: _rotatingAnimation.value * 2 * 3.14159,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.6),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (controller.detectedFaces.isNotEmpty)
                  Positioned.fill(
                    child: ClipOval(
                      child: CustomPaint(
                        painter: FaceOverlayPainter(
                          faces: controller.detectedFaces,
                          previewSize: Size(circleSize, circleSize),
                          cameraPreviewSize:
                              controller.cameraController?.value.previewSize,
                          currentState: controller.currentState,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraPreviewContent(FaceDetectionController controller) {
    if (!controller.isCameraInitialized ||
        controller.cameraController == null) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.camera_alt, size: 80, color: Colors.grey),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.cameraController!.value.previewSize!.height,
        height: controller.cameraController!.value.previewSize!.width,
        child: CameraPreview(controller.cameraController!),
      ),
    );
  }

  Widget _buildStatusSection(FaceDetectionController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(controller),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              controller.statusMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          _buildProgressIndicator(controller),

          const SizedBox(height: 16),

          if (controller.currentState == VerificationState.failed)
            ElevatedButton(
              onPressed: () => controller.reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(FaceDetectionController controller) {
    double progress = 0.0;

    switch (controller.currentState) {
      case VerificationState.positioning:
        progress = 0.2;
        break;
      case VerificationState.faceDetected:
        progress = 0.4;
        break;
      case VerificationState.waitingForBlink:
        progress = 0.6;
        break;
      case VerificationState.blinkDetected:
        progress = 0.8;
        break;
      case VerificationState.processing:
        progress = 0.9;
        break;
      case VerificationState.success:
      case VerificationState.failed:
        progress = 1.0;
        break;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            controller.currentState == VerificationState.failed
                ? Colors.red
                : Colors.blue,
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue, strokeWidth: 3),
            SizedBox(height: 24),
            Text(
              'Menginisialisasi AI Model...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Mohon tunggu sebentar',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCircleColor(FaceDetectionController controller) {
    switch (controller.currentState) {
      case VerificationState.positioning:
        return controller.isFaceInCircle ? Colors.orange : Colors.red;
      case VerificationState.faceDetected:
        return Colors.green;
      case VerificationState.waitingForBlink:
        return Colors.blue;
      case VerificationState.blinkDetected:
        return Colors.purple;
      case VerificationState.processing:
        return Colors.blue;
      case VerificationState.success:
        return Colors.green;
      case VerificationState.failed:
        return Colors.red;
    }
  }

  Color _getStatusBackgroundColor(FaceDetectionController controller) {
    switch (controller.currentState) {
      case VerificationState.positioning:
        return controller.isFaceInCircle ? Colors.orange : Colors.red;
      case VerificationState.faceDetected:
        return Colors.green;
      case VerificationState.waitingForBlink:
        return Colors.blue;
      case VerificationState.blinkDetected:
        return Colors.purple;
      case VerificationState.processing:
        return Colors.blue;
      case VerificationState.success:
        return Colors.green;
      case VerificationState.failed:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _circleAnimationController.dispose();
    _successAnimationController.dispose();
    _rotatingCircleController.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class FaceOverlayPainter extends CustomPainter {
  final List<dynamic> faces;
  final Size previewSize;
  final Size? cameraPreviewSize;
  final VerificationState currentState;

  FaceOverlayPainter({
    required this.faces,
    required this.previewSize,
    required this.cameraPreviewSize,
    required this.currentState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty || cameraPreviewSize == null) return;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final scaleX = size.width / cameraPreviewSize!.height;
    final scaleY = size.height / cameraPreviewSize!.width;

    for (final face in faces) {
      final boundingBox = face.boundingBox;

      final left = boundingBox.left * scaleX;
      final top = boundingBox.top * scaleY;
      final right = boundingBox.right * scaleX;
      final bottom = boundingBox.bottom * scaleY;

      final transformedRect = Rect.fromLTRB(left, top, right, bottom);

      Color boxColor;
      switch (currentState) {
        case VerificationState.positioning:
          boxColor = Colors.orange;
          break;
        case VerificationState.faceDetected:
          boxColor = Colors.green;
          break;
        case VerificationState.waitingForBlink:
          boxColor = Colors.blue;
          break;
        case VerificationState.blinkDetected:
          boxColor = Colors.purple;
          break;
        case VerificationState.processing:
          boxColor = Colors.blue;
          break;
        case VerificationState.success:
          boxColor = Colors.green;
          break;
        case VerificationState.failed:
          boxColor = Colors.red;
          break;
      }

      paint.color = boxColor;
      canvas.drawRect(transformedRect, paint);

      if (currentState == VerificationState.waitingForBlink &&
          face.landmarks != null) {
        paint.style = PaintingStyle.fill;
        paint.color = Colors.yellow;

        final landmarks = face.landmarks!;
        final leftEye = landmarks[FaceLandmarkType.leftEye];
        final rightEye = landmarks[FaceLandmarkType.rightEye];

        if (leftEye != null) {
          canvas.drawCircle(
            Offset(leftEye.position.dx * scaleX, leftEye.position.dy * scaleY),
            3.0,
            paint,
          );
        }
        if (rightEye != null) {
          canvas.drawCircle(
            Offset(
              rightEye.position.dx * scaleX,
              rightEye.position.dy * scaleY,
            ),
            3.0,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return faces != oldDelegate.faces ||
        currentState != oldDelegate.currentState ||
        previewSize != oldDelegate.previewSize;
  }
}
