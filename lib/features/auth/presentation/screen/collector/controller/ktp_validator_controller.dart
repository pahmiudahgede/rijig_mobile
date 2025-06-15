import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:nik_validator/nik_validator.dart';

enum KtpValidationState { initial, imageSelected, processing, success, error }

enum ProcessingStatus { idle, preprocessing, extracting, validating, completed }

class ImageProcessingData {
  final Uint8List imageBytes;
  final String imagePath;

  ImageProcessingData(this.imageBytes, this.imagePath);
}

class ProcessedImageResult {
  final String processedPath;
  final bool success;
  final String? error;

  ProcessedImageResult({
    required this.processedPath,
    required this.success,
    this.error,
  });
}

class KtpData {
  String identificationNumber;
  String fullName;
  String bloodType;
  String hamlet;
  String village;
  String neighbourhood;
  String religion;
  String maritalStatus;
  String job;
  String citizenship;
  String validUntil;
  String placeOfBirth;
  String dateOfBirth;
  String gender;
  String province;
  String district;
  String subDistrict;
  String postalCode;

  KtpData({
    this.identificationNumber = '',
    this.fullName = '',
    this.bloodType = '',
    this.hamlet = '',
    this.village = '',
    this.neighbourhood = '',
    this.religion = '',
    this.maritalStatus = '',
    this.job = '',
    this.citizenship = '',
    this.validUntil = '',
    this.placeOfBirth = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.province = '',
    this.district = '',
    this.subDistrict = '',
    this.postalCode = '',
  });

  void clear() {
    identificationNumber = '';
    fullName = '';
    bloodType = '';
    hamlet = '';
    village = '';
    neighbourhood = '';
    religion = '';
    maritalStatus = '';
    job = '';
    citizenship = '';
    validUntil = '';
    placeOfBirth = '';
    dateOfBirth = '';
    gender = '';
    province = '';
    district = '';
    subDistrict = '';
    postalCode = '';
  }

  bool get hasData => identificationNumber.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'identificationNumber': identificationNumber,
      'fullName': fullName,
      'bloodType': bloodType,
      'hamlet': hamlet,
      'village': village,
      'neighbourhood': neighbourhood,
      'religion': religion,
      'maritalStatus': maritalStatus,
      'job': job,
      'citizenship': citizenship,
      'validUntil': validUntil,
      'placeOfBirth': placeOfBirth,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'province': province,
      'district': district,
      'subDistrict': subDistrict,
      'postalCode': postalCode,
    };
  }
}

class KtpValidatorController extends ChangeNotifier {
  static const int _maxImageSize = 2048;
  static const int _imageQuality = 85;

  final ImagePicker _picker = ImagePicker();
  final KtpData _ktpData = KtpData();
  final Map<String, TextEditingController> _controllers = {};

  File? _selectedImage;
  File? _processedImage;
  KtpValidationState _state = KtpValidationState.initial;
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  String _errorMessage = '';
  String _successMessage = '';
  TextRecognizer? _textRecognizer;

  // Getters tetap sama
  KtpValidationState get state => _state;
  ProcessingStatus get processingStatus => _processingStatus;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  File? get selectedImage => _selectedImage;
  KtpData get ktpData => _ktpData;
  Map<String, TextEditingController> get controllers => _controllers;
  bool get isProcessing => _state == KtpValidationState.processing;
  bool get hasData => _ktpData.hasData;
  bool get canProcessImage => _selectedImage != null && !isProcessing;

  void initialize() {
    _initializeControllers();
    _initializeTextRecognizer();
  }

  void _initializeControllers() {
    final fields = [
      'nik',
      'name',
      'placeOfBirth',
      'dateOfBirth',
      'gender',
      'bloodType',
      'hamlet',
      'village',
      'neighbourhood',
      'religion',
      'maritalStatus',
      'job',
      'citizenship',
      'validUntil',
      'province',
      'district',
      'subDistrict',
      'postalCode',
    ];

    for (String field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  void _initializeTextRecognizer() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<void> pickImageFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: _imageQuality,
        maxWidth: _maxImageSize.toDouble(),
        maxHeight: _maxImageSize.toDouble(),
      );

      if (image != null) {
        _cleanupTempFiles();
        _selectedImage = File(image.path);
        _processedImage = null;
        _ktpData.clear();
        _clearControllers();

        _updateState(KtpValidationState.imageSelected);
        _clearMessages();
      }
    } catch (e) {
      _handleError('Error saat memilih gambar: $e');
    }
  }

  Future<void> processImage() async {
    if (_selectedImage == null || _textRecognizer == null) return;

    _updateState(KtpValidationState.processing);
    _updateProcessingStatus(ProcessingStatus.preprocessing);
    _ktpData.clear();
    _clearControllers();

    try {
      // Improved image processing
      final ProcessedImageResult result = await _processImageOptimized(
        _selectedImage!,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Image processing failed');
      }

      _processedImage = File(result.processedPath);
      _updateProcessingStatus(ProcessingStatus.extracting);

      // Enhanced OCR with multiple attempts
      final String extractedNIK = await _performMultipleOCRAttempts(
        _processedImage!,
      );

      if (extractedNIK.isEmpty) {
        throw Exception(
          'NIK tidak ditemukan. Pastikan foto KTP jelas dan tidak buram.',
        );
      }

      _updateProcessingStatus(ProcessingStatus.validating);

      await _parseNIK(extractedNIK);

      _updateProcessingStatus(ProcessingStatus.completed);
      _updateControllers();
      _updateState(KtpValidationState.success);
      _setSuccessMessage('NIK berhasil terdeteksi: $extractedNIK');
    } catch (e) {
      _handleError('Error saat memproses gambar: $e');
    }
  }

  Future<String> _performMultipleOCRAttempts(File processedImage) async {
    try {
      // Attempt 1: Original processed image
      String nik = await _performEnhancedOCR(processedImage);
      if (nik.isNotEmpty) {
        debugPrint('NIK found in attempt 1: $nik');
        return nik;
      }

      // Attempt 2: Try with different image processing
      final File alternativeProcessed = await _createAlternativeProcessedImage(
        processedImage,
      );
      nik = await _performEnhancedOCR(alternativeProcessed);
      if (nik.isNotEmpty) {
        debugPrint('NIK found in attempt 2: $nik');
        return nik;
      }

      // Attempt 3: Try with original image (no processing)
      nik = await _performEnhancedOCR(_selectedImage!);
      if (nik.isNotEmpty) {
        debugPrint('NIK found in attempt 3 (original): $nik');
        return nik;
      }

      debugPrint('NIK not found in any attempt');
      return '';
    } catch (e) {
      debugPrint('Multiple OCR attempts error: $e');
      return '';
    }
  }

  Future<File> _createAlternativeProcessedImage(File originalProcessed) async {
    try {
      final Uint8List imageBytes = await originalProcessed.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return originalProcessed;

      img.Image processed = image;

      // Different processing approach
      processed = img.adjustColor(processed, contrast: 1.6, brightness: 1.2);
      processed = img.gaussianBlur(processed, radius: 1);
      processed = img.adjustColor(processed, contrast: 1.3);

      // Apply threshold for better text recognition
      processed = _applyThreshold(processed, 128);

      final String altProcessedPath = originalProcessed.path.replaceAll(
        '_processed.jpg',
        '_alt_processed.jpg',
      );
      final File altProcessedFile = File(altProcessedPath);
      await altProcessedFile.writeAsBytes(
        img.encodeJpg(processed, quality: 95),
      );

      return altProcessedFile;
    } catch (e) {
      debugPrint('Alternative processing error: $e');
      return originalProcessed;
    }
  }

  img.Image _applyThreshold(img.Image image, int threshold) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final gray = img.getLuminance(pixel);
        final newPixel =
            gray > threshold
                ? img.ColorRgb8(255, 255, 255)
                : img.ColorRgb8(0, 0, 0);
        image.setPixel(x, y, newPixel);
      }
    }
    return image;
  }

  Future<ProcessedImageResult> _processImageOptimized(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      return await compute(
        _processImageInIsolate,
        ImageProcessingData(imageBytes, imageFile.path),
      );
    } catch (e) {
      return ProcessedImageResult(
        processedPath: imageFile.path,
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<String> _performEnhancedOCR(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer!.processImage(
        inputImage,
      );

      // Debug: Print all detected text
      debugPrint('OCR Raw Text: ${recognizedText.text}');

      // Print each text block for debugging
      for (TextBlock block in recognizedText.blocks) {
        debugPrint('Text Block: ${block.text}');
        for (TextLine line in block.lines) {
          debugPrint('Text Line: ${line.text}');
        }
      }

      // Try multiple extraction methods
      String nik = _extractNIKEnhanced(recognizedText.text);
      if (nik.isNotEmpty) return nik;

      nik = _extractNIKFromBlocks(recognizedText.blocks);
      if (nik.isNotEmpty) return nik;

      nik = _extractNIKFallback(recognizedText.text);
      return nik;
    } catch (e) {
      debugPrint('OCR Error: $e');
      return '';
    }
  }

  // IMPROVED: Enhanced NIK extraction with better patterns
  String _extractNIKEnhanced(String ocrText) {
    final List<RegExp> nikPatterns = [
      // Standard 16 digits
      RegExp(r'\b(\d{16})\b'),
      // With spaces or separators
      RegExp(r'(\d{2}[\s\-_]?\d{2}[\s\-_]?\d{2}[\s\-_]?\d{6}[\s\-_]?\d{4})'),
      RegExp(r'(\d{4}[\s\-_]?\d{4}[\s\-_]?\d{4}[\s\-_]?\d{4})'),
      // More flexible patterns
      RegExp(r'(\d{2}\s*\d{2}\s*\d{2}\s*\d{6}\s*\d{4})'),
      RegExp(r'(\d{6}\s*\d{6}\s*\d{4})'),
      // Looking for NIK label followed by numbers
      RegExp(r'(?:NIK|No\.?\s*KTP)[\s:]*(\d{16})', caseSensitive: false),
      RegExp(
        r'(?:NIK|No\.?\s*KTP)[\s:]*(\d{2}[\s\-_]?\d{2}[\s\-_]?\d{2}[\s\-_]?\d{6}[\s\-_]?\d{4})',
        caseSensitive: false,
      ),
    ];

    // Clean text for better matching
    String cleanText =
        ocrText
            .replaceAll(RegExp(r'[^\d\s\-_:]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    debugPrint('Clean text for NIK extraction: $cleanText');

    for (RegExp pattern in nikPatterns) {
      final Match? match = pattern.firstMatch(ocrText);
      if (match != null) {
        String candidate = match.group(1) ?? match.group(0)!;
        candidate = candidate.replaceAll(RegExp(r'[\s\-_]+'), '');

        debugPrint('Pattern matched candidate: $candidate');

        if (candidate.length == 16 && _isValidNIKFormat(candidate)) {
          debugPrint('Valid NIK found: $candidate');
          return candidate;
        }
      }
    }

    return '';
  }

  String _extractNIKFromBlocks(List<TextBlock> blocks) {
    for (TextBlock block in blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text;
        debugPrint('Checking line: $lineText');

        // Look for lines that might contain NIK
        if (lineText.toLowerCase().contains('nik') ||
            lineText.toLowerCase().contains('ktp') ||
            RegExp(r'\d{12,}').hasMatch(lineText)) {
          String nik = _extractNIKEnhanced(lineText);
          if (nik.isNotEmpty) {
            debugPrint('NIK found in line: $lineText -> $nik');
            return nik;
          }
        }
      }
    }
    return '';
  }

  String _extractNIKFallback(String ocrText) {
    final RegExp numberPattern = RegExp(r'\d+');
    final Iterable<Match> matches = numberPattern.allMatches(ocrText);

    for (Match match in matches) {
      String candidate = match.group(0)!;

      if (candidate.length == 16 && _isValidNIKFormat(candidate)) {
        return candidate;
      }

      if (candidate.length > 16) {
        for (int i = 0; i <= candidate.length - 16; i++) {
          String subCandidate = candidate.substring(i, i + 16);
          if (_isValidNIKFormat(subCandidate)) {
            return subCandidate;
          }
        }
      }
    }

    return '';
  }

  bool _isValidNIKFormat(String nik) {
    if (nik.length != 16) return false;

    int provinceCode = int.tryParse(nik.substring(0, 2)) ?? 0;
    if (provinceCode < 11 || provinceCode > 94) return false;

    int regencyCode = int.tryParse(nik.substring(2, 4)) ?? 0;
    if (regencyCode < 1 || regencyCode > 99) return false;

    int districtCode = int.tryParse(nik.substring(4, 6)) ?? 0;
    if (districtCode < 1 || districtCode > 99) return false;

    String birthDate = nik.substring(6, 12);
    int day = int.tryParse(birthDate.substring(0, 2)) ?? 0;
    int month = int.tryParse(birthDate.substring(2, 4)) ?? 0;

    if (day > 40) day -= 40;

    if (day < 1 || day > 31) return false;
    if (month < 1 || month > 12) return false;

    return true;
  }

  Future<void> _parseNIK(String nik) async {
    try {
      final NIKModel result = await NIKValidator.instance.parse(nik: nik);

      if (result.valid == true) {
        _ktpData.identificationNumber = result.nik ?? '';
        _ktpData.gender = result.gender ?? '';
        _ktpData.dateOfBirth = result.bornDate ?? '';
        _ktpData.province = result.province ?? '';
        _ktpData.district = result.city ?? '';
        _ktpData.subDistrict = result.subdistrict ?? '';
        _ktpData.postalCode = result.postalCode ?? '';
      } else {
        throw Exception('NIK tidak valid: $nik');
      }
    } catch (e) {
      throw Exception('Error saat memvalidasi NIK: $e');
    }
  }

  void updateControllerValue(String key, String value) {
    if (_controllers.containsKey(key)) {
      _controllers[key]?.text = value;
    }
  }

  void _updateControllers() {
    _controllers['nik']?.text = _ktpData.identificationNumber;
    _controllers['name']?.text = _ktpData.fullName;
    _controllers['placeOfBirth']?.text = _ktpData.placeOfBirth;
    _controllers['dateOfBirth']?.text = _ktpData.dateOfBirth;
    _controllers['gender']?.text = _ktpData.gender;
    _controllers['bloodType']?.text = _ktpData.bloodType;
    _controllers['hamlet']?.text = _ktpData.hamlet;
    _controllers['village']?.text = _ktpData.village;
    _controllers['neighbourhood']?.text = _ktpData.neighbourhood;
    _controllers['religion']?.text = _ktpData.religion;
    _controllers['maritalStatus']?.text = _ktpData.maritalStatus;
    _controllers['job']?.text = _ktpData.job;
    _controllers['citizenship']?.text = _ktpData.citizenship;
    _controllers['validUntil']?.text = _ktpData.validUntil;
    _controllers['province']?.text = _ktpData.province;
    _controllers['district']?.text = _ktpData.district;
    _controllers['subDistrict']?.text = _ktpData.subDistrict;
    _controllers['postalCode']?.text = _ktpData.postalCode;
  }

  void _clearControllers() {
    for (var controller in _controllers.values) {
      controller.clear();
    }
  }

  bool validateForm() {
    final nikValue = _controllers['nik']?.text ?? '';
    final nameValue = _controllers['name']?.text ?? '';

    if (nikValue.length != 16) {
      _handleError('NIK harus 16 digit');
      return false;
    }

    if (nameValue.isEmpty) {
      _handleError('Nama lengkap harus diisi');
      return false;
    }

    return true;
  }

  Future<bool> saveData() async {
    if (!validateForm()) return false;

    try {
      _ktpData.identificationNumber = _controllers['nik']?.text ?? '';
      _ktpData.fullName = _controllers['name']?.text ?? '';
      _ktpData.placeOfBirth = _controllers['placeOfBirth']?.text ?? '';
      _ktpData.dateOfBirth = _controllers['dateOfBirth']?.text ?? '';
      _ktpData.gender = _controllers['gender']?.text ?? '';
      _ktpData.bloodType = _controllers['bloodType']?.text ?? '';
      _ktpData.neighbourhood = _controllers['neighbourhood']?.text ?? '';
      _ktpData.village = _controllers['village']?.text ?? '';
      _ktpData.religion = _controllers['religion']?.text ?? '';
      _ktpData.maritalStatus = _controllers['maritalStatus']?.text ?? '';
      _ktpData.job = _controllers['job']?.text ?? '';
      _ktpData.citizenship = _controllers['citizenship']?.text ?? '';
      _ktpData.validUntil = _controllers['validUntil']?.text ?? '';

      await Future.delayed(const Duration(milliseconds: 500));

      _setSuccessMessage('Data KTP berhasil disimpan!');
      debugPrint('KTP Data saved: ${_ktpData.toJson()}');

      return true;
    } catch (e) {
      _handleError('Error saat menyimpan data: $e');
      return false;
    }
  }

  void _updateState(KtpValidationState newState) {
    _state = newState;
    notifyListeners();
  }

  void _updateProcessingStatus(ProcessingStatus status) {
    _processingStatus = status;
    notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
    _successMessage = '';
    _updateState(KtpValidationState.error);
    debugPrint('KTP Validation Error: $message');
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = '';
  }

  void _clearMessages() {
    _errorMessage = '';
    _successMessage = '';
  }

  void clearError() {
    _errorMessage = '';
    if (_state == KtpValidationState.error) {
      _updateState(
        _selectedImage != null
            ? KtpValidationState.imageSelected
            : KtpValidationState.initial,
      );
    }
  }

  void _cleanupTempFiles() {
    try {
      _processedImage?.deleteSync();
    } catch (e) {
      debugPrint('Error cleaning temp files: $e');
    }
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _cleanupTempFiles();
    super.dispose();
  }
}

Future<ProcessedImageResult> _processImageInIsolate(
  ImageProcessingData data,
) async {
  try {
    img.Image? image = img.decodeImage(data.imageBytes);
    if (image == null) {
      return ProcessedImageResult(
        processedPath: data.imagePath,
        success: false,
        error: 'Failed to decode image',
      );
    }

    img.Image processed = image;

    processed = img.grayscale(processed);

    processed = img.adjustColor(processed, contrast: 1.4, brightness: 1.1);

    processed = img.convolution(
      processed,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );

    if (processed.width < 1200) {
      processed = img.copyResize(processed, width: 1200);
    } else if (processed.width > 1600) {
      processed = img.copyResize(processed, width: 1600);
    }

    processed = img.gaussianBlur(processed, radius: 1);

    processed = img.adjustColor(processed, contrast: 1.2);

    processed = img.normalize(processed, min: 0, max: 255);

    final String processedPath = data.imagePath.replaceAll(
      '.jpg',
      '_processed.jpg',
    );
    final File processedFile = File(processedPath);
    await processedFile.writeAsBytes(img.encodeJpg(processed, quality: 95));

    return ProcessedImageResult(processedPath: processedPath, success: true);
  } catch (e) {
    return ProcessedImageResult(
      processedPath: data.imagePath,
      success: false,
      error: e.toString(),
    );
  }
}
