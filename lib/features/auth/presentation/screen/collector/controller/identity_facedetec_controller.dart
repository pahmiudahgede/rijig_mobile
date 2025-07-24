import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum VerificationState {
  positioning,
  faceDetected,
  waitingForBlink,
  blinkDetected,
  processing,
  success,
  failed,
}

class FaceDetectionController extends ChangeNotifier {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Interpreter? _interpreter;
  bool _isTfliteInitialized = false;

  List<Face> _detectedFaces = [];
  VerificationState _currentState = VerificationState.positioning;
  String _statusMessage = 'Menginisialisasi...';
  bool _isFaceInCircle = false;
  bool _isFaceStable = false;

  int _eyeClosedFrames = 0;
  int _eyeOpenFrames = 0;
  bool _wasEyeClosed = false;
  static const int _blinkThreshold = 4;
  int _stableFrames = 0;
  static const int _stabilityThreshold = 15;

  List<double>? _referenceEmbedding;
  double _lastSimilarityScore = 0.0;
  static const double _verificationThreshold = 0.75;

  int _frameSkipCount = 0;
  static const int _frameSkipInterval = 2;
  DateTime? _lastDetectionTime;
  static const int _detectionCooldown = 33;

  bool _shouldShowCircleAnimation = false;
  bool _shouldShowSuccessAnimation = false;

  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isTfliteInitialized => _isTfliteInitialized;
  bool get isDetecting => _isDetecting;
  List<Face> get detectedFaces => _detectedFaces;
  VerificationState get currentState => _currentState;
  String get statusMessage => _statusMessage;
  bool get isFaceInCircle => _isFaceInCircle;
  bool get isFaceStable => _isFaceStable;
  bool get hasReferenceFace => _referenceEmbedding != null;
  double get lastSimilarityScore => _lastSimilarityScore;
  bool get shouldShowCircleAnimation => _shouldShowCircleAnimation;
  bool get shouldShowSuccessAnimation => _shouldShowSuccessAnimation;

  Future<void> initializeTflite() async {
    try {
      debugPrint('Loading MobileFaceNet model...');
      _interpreter = await Interpreter.fromAsset('mobilefacenet.tflite');
      _isTfliteInitialized = true;

      final inputDetails = _interpreter!.getInputTensor(0);
      final outputDetails = _interpreter!.getOutputTensor(0);
      debugPrint(
        'Model loaded - Input: ${inputDetails.shape}, Output: ${outputDetails.shape}',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading TensorFlow Lite model: $e');
      _statusMessage = 'Error: Gagal memuat model AI';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia');
      }

      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;

      _cameraController!.startImageStream(_processCameraImage);

      _statusMessage = 'Posisikan wajah Anda dalam lingkaran';
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _statusMessage = 'Error: Gagal menginisialisasi kamera';
      notifyListeners();
    }
  }

  Future<void> loadReferenceFaceFromAssets(String assetPath) async {
    if (!_isTfliteInitialized) {
      throw Exception('TensorFlow Lite belum diinisialisasi');
    }

    try {
      debugPrint('Loading reference face from $assetPath');
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List imageBytes = data.buffer.asUint8List();

      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Gagal decode gambar referensi');
      }

      final preprocessedImage = _preprocessImageForTflite(image);

      _referenceEmbedding = await _generateEmbedding(preprocessedImage);

      if (_referenceEmbedding == null) {
        throw Exception('Gagal generate embedding dari gambar referensi');
      }

      debugPrint('Reference face embedding generated successfully');
      debugPrint('Embedding dimensions: ${_referenceEmbedding!.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reference face: $e');
      rethrow;
    }
  }

  Float32List _preprocessImageForTflite(img.Image image) {
    final resizedImage = img.copyResize(
      image,
      width: 112,
      height: 112,
      interpolation: img.Interpolation.cubic,
    );

    final Float32List inputData = Float32List(1 * 112 * 112 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = resizedImage.getPixel(x, y);

        inputData[pixelIndex * 3 + 0] = (pixel.r - 127.5) / 127.5;
        inputData[pixelIndex * 3 + 1] = (pixel.g - 127.5) / 127.5;
        inputData[pixelIndex * 3 + 2] = (pixel.b - 127.5) / 127.5;

        pixelIndex++;
      }
    }

    return inputData;
  }

  Future<List<double>?> _generateEmbedding(Float32List inputData) async {
    try {
      if (_interpreter == null) return null;

      final input = inputData.reshape([1, 112, 112, 3]);
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;
      final embeddingSize = outputShape[1];

      final output = List.filled(
        1 * embeddingSize,
        0.0,
      ).reshape([1, embeddingSize]);

      _interpreter!.run(input, output);

      final embedding = output[0].cast<double>();

      double norm = 0.0;
      for (double value in embedding) {
        norm += value * value;
      }
      norm = math.sqrt(norm);

      if (norm > 0) {
        for (int i = 0; i < embedding.length; i++) {
          embedding[i] = embedding[i] / norm;
        }
      }

      return embedding;
    } catch (e) {
      debugPrint('Error generating embedding: $e');
      return null;
    }
  }

  void _processCameraImage(CameraImage image) async {
    _frameSkipCount++;
    if (_frameSkipCount % _frameSkipInterval != 0) return;

    final now = DateTime.now();
    if (_lastDetectionTime != null &&
        now.difference(_lastDetectionTime!).inMilliseconds <
            _detectionCooldown) {
      return;
    }

    if (_isDetecting) return;
    _isDetecting = true;
    _lastDetectionTime = now;

    try {
      final inputImage = _cameraImageToInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      _detectedFaces = faces;

      await _updateVerificationState(faces, image);

      notifyListeners();
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _updateVerificationState(
    List<Face> faces,
    CameraImage image,
  ) async {
    if (faces.isEmpty) {
      _resetToPositioning('Tidak ada wajah terdeteksi');
      return;
    }

    if (faces.length > 1) {
      _resetToPositioning('Terlalu banyak wajah terdeteksi');
      return;
    }

    final face = faces.first;
    _updateFacePosition(face, image);

    switch (_currentState) {
      case VerificationState.positioning:
        if (_isFaceInCircle && _isFaceStable) {
          _stableFrames++;
          if (_stableFrames >= _stabilityThreshold) {
            _currentState = VerificationState.faceDetected;
            _statusMessage = 'Wajah terdeteksi dengan baik';
            _shouldShowCircleAnimation = true;
            _stableFrames = 0;
          } else {
            _statusMessage =
                'Stabilisasi wajah... ${(_stableFrames / _stabilityThreshold * 100).toInt()}%';
          }
        } else {
          _stableFrames = 0;
          if (!_isFaceInCircle) {
            _statusMessage = 'Posisikan wajah dalam lingkaran';
          } else {
            _statusMessage = 'Sesuaikan jarak wajah';
          }
        }
        break;

      case VerificationState.faceDetected:
        if (!_isFaceInCircle || !_isFaceStable) {
          _resetToPositioning('Posisi wajah berubah');
          return;
        }

        _stableFrames++;
        if (_stableFrames >= 30) {
          _currentState = VerificationState.waitingForBlink;
          _statusMessage = 'Silakan berkedip sekali';
          _resetBlinkDetection();
        } else {
          _statusMessage = 'Bersiap untuk verifikasi...';
        }
        break;

      case VerificationState.waitingForBlink:
        if (!_isFaceInCircle || !_isFaceStable) {
          _resetToPositioning('Posisi wajah berubah');
          return;
        }

        _processBlink(face);
        break;

      case VerificationState.blinkDetected:
        if (_currentState == VerificationState.blinkDetected) {
          _currentState = VerificationState.processing;
          _statusMessage = 'Memverifikasi wajah...';

          _performFaceComparison();
        }
        break;

      case VerificationState.processing:
      case VerificationState.success:
      case VerificationState.failed:
        break;
    }
  }

  void _updateFacePosition(Face face, CameraImage image) {
    final imageCenter = Offset(image.width / 2, image.height / 2);
    final faceCenter = Offset(
      face.boundingBox.left + face.boundingBox.width / 2,
      face.boundingBox.top + face.boundingBox.height / 2,
    );

    final distance = (faceCenter - imageCenter).distance;
    final circleRadius = math.min(image.width, image.height) * 0.35;
    _isFaceInCircle = distance < circleRadius;

    final faceSize = face.boundingBox.width * face.boundingBox.height;
    final imageSize = image.width * image.height;
    final faceSizeRatio = faceSize / imageSize;
    _isFaceStable = faceSizeRatio > 0.04 && faceSizeRatio < 0.45;
  }

  void _processBlink(Face face) {
    if (face.leftEyeOpenProbability == null ||
        face.rightEyeOpenProbability == null) {
      _statusMessage = 'Deteksi mata tidak tersedia';
      return;
    }

    final leftEyeOpen = face.leftEyeOpenProbability! > 0.6;
    final rightEyeOpen = face.rightEyeOpenProbability! > 0.6;
    final bothEyesOpen = leftEyeOpen && rightEyeOpen;

    if (bothEyesOpen) {
      _eyeOpenFrames++;
      _eyeClosedFrames = 0;

      if (_wasEyeClosed && _eyeOpenFrames >= _blinkThreshold) {
        _currentState = VerificationState.blinkDetected;
        _statusMessage = 'Berkedip terdeteksi!';
        debugPrint('Blink detected successfully');
      } else if (_wasEyeClosed) {
        _statusMessage = 'Membuka mata...';
      } else {
        _statusMessage = 'Silakan berkedip sekali';
      }

      if (_eyeOpenFrames >= _blinkThreshold) {
        _wasEyeClosed = false;
      }
    } else {
      _eyeClosedFrames++;
      _eyeOpenFrames = 0;

      if (_eyeClosedFrames >= _blinkThreshold) {
        _wasEyeClosed = true;
        _statusMessage = 'Mata tertutup - buka kembali';
      } else {
        _statusMessage = 'Menutup mata...';
      }
    }
  }

  Future<void> _performFaceComparison() async {
    try {
      if (_referenceEmbedding == null || _detectedFaces.isEmpty) {
        _currentState = VerificationState.failed;
        _statusMessage = 'Error: Data referensi tidak tersedia';
        return;
      }

      final XFile imageFile = await _cameraController!.takePicture();
      final bytes = await imageFile.readAsBytes();

      final croppedFace = await _cropFaceFromImage(bytes, _detectedFaces.first);
      if (croppedFace == null) {
        _currentState = VerificationState.failed;
        _statusMessage = 'Error: Gagal memproses gambar';
        return;
      }

      final img.Image? currentImage = img.decodeImage(croppedFace);
      if (currentImage == null) {
        _currentState = VerificationState.failed;
        _statusMessage = 'Error: Gagal decode gambar';
        return;
      }

      final preprocessedImage = _preprocessImageForTflite(currentImage);
      final currentEmbedding = await _generateEmbedding(preprocessedImage);

      if (currentEmbedding == null) {
        _currentState = VerificationState.failed;
        _statusMessage = 'Error: Gagal generate embedding';
        return;
      }

      final similarity = _calculateCosineSimilarity(
        _referenceEmbedding!,
        currentEmbedding,
      );
      _lastSimilarityScore = similarity;

      debugPrint(
        'Face comparison result: ${(similarity * 100).toStringAsFixed(2)}%',
      );

      if (similarity >= _verificationThreshold) {
        _currentState = VerificationState.success;
        _statusMessage = 'Verifikasi berhasil!';
        _shouldShowSuccessAnimation = true;
      } else {
        _currentState = VerificationState.failed;
        _statusMessage = 'Verifikasi gagal - wajah tidak cocok';
      }
    } catch (e) {
      debugPrint('Error in face comparison: $e');
      _currentState = VerificationState.failed;
      _statusMessage = 'Error: Gagal memverifikasi wajah';
    }
  }

  void _resetToPositioning(String message) {
    _currentState = VerificationState.positioning;
    _statusMessage = message;
    _stableFrames = 0;
    _shouldShowCircleAnimation = false;
    _resetBlinkDetection();
  }

  void _resetBlinkDetection() {
    _eyeClosedFrames = 0;
    _eyeOpenFrames = 0;
    _wasEyeClosed = false;
  }

  InputImage? _cameraImageToInputImage(CameraImage image) {
    try {
      final camera = _cameraController?.description;
      if (camera == null) return null;

      final sensorOrientation = camera.sensorOrientation;
      InputImageRotation? rotation;

      if (Platform.isIOS) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      } else if (Platform.isAndroid) {
        var rotationCompensation =
            _cameraController!.value.deviceOrientation.index * 90;
        if (camera.lensDirection == CameraLensDirection.front) {
          rotationCompensation = -rotationCompensation;
        }
        final finalRotation = (sensorOrientation + rotationCompensation) % 360;
        rotation = InputImageRotationValue.fromRawValue(finalRotation);
      }

      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      return InputImage.fromBytes(
        bytes: _concatenatePlanes(image.planes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<Uint8List?> _cropFaceFromImage(Uint8List imageBytes, Face face) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      final faceWidth = face.boundingBox.width;
      final faceHeight = face.boundingBox.height;
      final padding = math.max(faceWidth, faceHeight) * 0.3;

      final left = (face.boundingBox.left - padding).clamp(
        0,
        originalImage.width,
      );
      final top = (face.boundingBox.top - padding).clamp(
        0,
        originalImage.height,
      );
      final right = (face.boundingBox.right + padding).clamp(
        0,
        originalImage.width,
      );
      final bottom = (face.boundingBox.bottom + padding).clamp(
        0,
        originalImage.height,
      );

      final croppedImage = img.copyCrop(
        originalImage,
        x: left.toInt(),
        y: top.toInt(),
        width: (right - left).toInt(),
        height: (bottom - top).toInt(),
      );

      return Uint8List.fromList(img.encodePng(croppedImage));
    } catch (e) {
      debugPrint('Error cropping face: $e');
      return null;
    }
  }

  double _calculateCosineSimilarity(
    List<double> embedding1,
    List<double> embedding2,
  ) {
    if (embedding1.length != embedding2.length) return 0.0;

    double dotProduct = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
    }

    return dotProduct.clamp(-1.0, 1.0);
  }

  void reset() {
    _currentState = VerificationState.positioning;
    _statusMessage = 'Posisikan wajah Anda dalam lingkaran';
    _lastSimilarityScore = 0.0;
    _stableFrames = 0;
    _shouldShowCircleAnimation = false;
    _shouldShowSuccessAnimation = false;
    _resetBlinkDetection();
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector.close();
    _interpreter?.close();
    super.dispose();
  }
}
