import 'dart:io';
import 'dart:math' as math;

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
  final String processingType;

  ImageProcessingData(this.imageBytes, this.imagePath, this.processingType);
}

class ProcessedImageResult {
  final String processedPath;
  final bool success;
  final String? error;
  final double quality;
  final String processingType;

  ProcessedImageResult({
    required this.processedPath,
    required this.success,
    this.error,
    this.quality = 0.0,
    required this.processingType,
  });
}

class NIKCandidate {
  final String nik;
  final double confidence;
  final String source;
  final Map<String, dynamic> metadata;

  NIKCandidate({
    required this.nik,
    required this.confidence,
    required this.source,
    this.metadata = const {},
  });
}

class OCRCache {
  final Map<String, List<NIKCandidate>> _cache = {};
  final int _maxCacheSize = 10;

  void put(String key, List<NIKCandidate> candidates) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = candidates;
  }

  List<NIKCandidate>? get(String key) => _cache[key];
  void clear() => _cache.clear();
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

class OptimizedKtpValidatorController extends ChangeNotifier {
  static const int _maxImageSize = 2048;
  static const int _imageQuality = 85;
  static const double _minConfidenceThreshold = 0.6;

  final ImagePicker _picker = ImagePicker();
  final KtpData _ktpData = KtpData();
  final Map<String, TextEditingController> _controllers = {};
  final OCRCache _ocrCache = OCRCache();

  File? _selectedImage;
  File? _processedImage;
  KtpValidationState _state = KtpValidationState.initial;
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  String _errorMessage = '';
  String _successMessage = '';
  TextRecognizer? _textRecognizer;

  List<NIKCandidate> _nikCandidates = [];
  String _selectedNik = '';
  String? _currentImageHash;

  final Stopwatch _processingStopwatch = Stopwatch();

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
  List<String> get nikCandidates => _nikCandidates.map((c) => c.nik).toList();

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
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        await _cleanupTempFiles();
        _selectedImage = File(image.path);
        _processedImage = null;
        _ktpData.clear();
        _clearControllers();
        _nikCandidates.clear();
        _currentImageHash = await _calculateImageHash(image.path);

        _updateState(KtpValidationState.imageSelected);
        _clearMessages();
      }
    } catch (e) {
      _handleError('Error saat memilih gambar: $e');
    }
  }

  Future<String> _calculateImageHash(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return bytes.length.toString() +
        bytes.first.toString() +
        bytes.last.toString();
  }

  Future<void> processImage() async {
    if (_selectedImage == null || _textRecognizer == null) return;

    _processingStopwatch.reset();
    _processingStopwatch.start();

    _updateState(KtpValidationState.processing);
    _updateProcessingStatus(ProcessingStatus.preprocessing);
    _ktpData.clear();
    _clearControllers();
    _nikCandidates.clear();

    try {
      if (_currentImageHash != null) {
        final cachedCandidates = _ocrCache.get(_currentImageHash!);
        if (cachedCandidates != null && cachedCandidates.isNotEmpty) {
          _nikCandidates = cachedCandidates;
          await _processBestCandidate();
          return;
        }
      }

      final List<ProcessedImageResult> processedVersions =
          await _createOptimizedProcessedVersions(_selectedImage!);

      _updateProcessingStatus(ProcessingStatus.extracting);

      final List<NIKCandidate> allCandidates = [];

      final originalCandidates = await _extractNIKCandidatesWithConfidence(
        _selectedImage!,
      );
      allCandidates.addAll(originalCandidates);

      for (final result in processedVersions) {
        if (result.success) {
          final candidates = await _extractNIKCandidatesWithConfidence(
            File(result.processedPath),
            sourceWeight: result.quality,
          );
          allCandidates.addAll(candidates);
        }
      }

      _updateProcessingStatus(ProcessingStatus.validating);

      _nikCandidates = _rankAndFilterCandidates(allCandidates);

      if (_nikCandidates.isEmpty) {
        throw Exception(
          'NIK tidak ditemukan. Pastikan foto KTP jelas dan seluruh area KTP terlihat.',
        );
      }

      if (_currentImageHash != null) {
        _ocrCache.put(_currentImageHash!, _nikCandidates);
      }

      await _processBestCandidate();
    } catch (e) {
      _handleError('Error saat memproses gambar: $e');
    } finally {
      _processingStopwatch.stop();
      debugPrint(
        'Processing time: ${_processingStopwatch.elapsedMilliseconds}ms',
      );
    }
  }

  Future<void> _processBestCandidate() async {
    _selectedNik = _nikCandidates.first.nik;
    await _parseNIK(_selectedNik);

    _updateProcessingStatus(ProcessingStatus.completed);
    _updateControllers();
    _updateState(KtpValidationState.success);

    final confidence = (_nikCandidates.first.confidence * 100).toInt();
    _setSuccessMessage(
      'NIK terdeteksi: $_selectedNik (akurasi: $confidence%)'
      '${_nikCandidates.length > 1 ? ' - ${_nikCandidates.length} kandidat' : ''}',
    );
  }

  Future<List<ProcessedImageResult>> _createOptimizedProcessedVersions(
    File imageFile,
  ) async {
    final List<ProcessedImageResult> results = [];

    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();

      final result1 = await compute(
        _processImageEnhanced,
        ImageProcessingData(imageBytes, imageFile.path, 'enhanced'),
      );
      results.add(result1);

      final result2 = await compute(
        _processImageAdaptive,
        ImageProcessingData(imageBytes, imageFile.path, 'adaptive'),
      );
      results.add(result2);
    } catch (e) {
      debugPrint('Error creating processed versions: $e');
    }

    return results;
  }

  Future<List<NIKCandidate>> _extractNIKCandidatesWithConfidence(
    File imageFile, {
    double sourceWeight = 1.0,
  }) async {
    final List<NIKCandidate> candidates = [];

    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer!.processImage(
        inputImage,
      );

      candidates.addAll(
        _extractCandidatesFromText(
          recognizedText.text,
          'full_text',
          sourceWeight,
        ),
      );

      for (int i = 0; i < recognizedText.blocks.length; i++) {
        final block = recognizedText.blocks[i];
        candidates.addAll(
          _extractCandidatesFromText(
            block.text,
            'block_$i',
            sourceWeight * 0.9,
          ),
        );

        for (int j = 0; j < block.lines.length; j++) {
          final line = block.lines[j];
          candidates.addAll(
            _extractCandidatesFromText(
              line.text,
              'line_${i}_$j',
              sourceWeight * 0.8,
            ),
          );
        }
      }

      candidates.addAll(
        _extractNIKWithContext(recognizedText.blocks, sourceWeight),
      );
    } catch (e) {
      debugPrint('OCR Error: $e');
    }

    return candidates;
  }

  List<NIKCandidate> _extractCandidatesFromText(
    String text,
    String source,
    double sourceWeight,
  ) {
    final List<NIKCandidate> candidates = [];
    final String cleanedText = _cleanOCRErrors(text);

    final List<Map<String, dynamic>> patterns = [
      {
        'pattern': RegExp(r'\b(\d{16})\b'),
        'confidence': 1.0,
        'name': 'exact_16_digits',
      },
      {
        'pattern': RegExp(
          r'(\d{2}[\s\-\.]{0,2}\d{2}[\s\-\.]{0,2}\d{2}[\s\-\.]{0,2}\d{6}[\s\-\.]{0,2}\d{4})',
        ),
        'confidence': 0.9,
        'name': 'formatted_nik',
      },
      {
        'pattern': RegExp(
          r'(?:NIK|No\.?\s*KTP|Nomor|No)[\s:]*(\d{16})',
          caseSensitive: false,
        ),
        'confidence': 1.0,
        'name': 'labeled_nik',
      },
      {
        'pattern': RegExp(r'([0-9oOlI]{16})'),
        'confidence': 0.7,
        'name': 'ocr_errors',
      },
    ];

    for (final patternInfo in patterns) {
      final RegExp pattern = patternInfo['pattern'];
      final double baseConfidence = patternInfo['confidence'];
      final String patternName = patternInfo['name'];

      final matches = pattern.allMatches(cleanedText);
      for (final match in matches) {
        String candidate = match.group(1) ?? match.group(0)!;
        candidate = _normalizeNIK(candidate);

        if (candidate.length == 16 && _isValidNIKStructure(candidate)) {
          final confidence = _calculateNIKConfidence(
            candidate,
            cleanedText,
            patternName,
          );
          candidates.add(
            NIKCandidate(
              nik: candidate,
              confidence: confidence * baseConfidence * sourceWeight,
              source: '$source-$patternName',
              metadata: {
                'pattern': patternName,
                'match_position': match.start,
                'context': _getContext(cleanedText, match.start, match.end),
              },
            ),
          );
        }
      }
    }

    return candidates;
  }

  List<NIKCandidate> _extractNIKWithContext(
    List<TextBlock> blocks,
    double sourceWeight,
  ) {
    final List<NIKCandidate> candidates = [];

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final lines = block.lines;

      for (int j = 0; j < lines.length - 1; j++) {
        final currentLine = lines[j].text.toLowerCase();
        final nextLine = lines[j + 1].text;

        if (_containsNIKIndicator(currentLine)) {
          final numbers = _extractNumbersOnly(nextLine);
          if (numbers.length >= 16) {
            final candidate = numbers.substring(0, 16);
            if (_isValidNIKStructure(candidate)) {
              final confidence = _calculateNIKConfidence(
                candidate,
                nextLine,
                'context_based',
              );
              candidates.add(
                NIKCandidate(
                  nik: candidate,
                  confidence: confidence * sourceWeight * 1.1,
                  source: 'context_block_$i',
                  metadata: {
                    'indicator_line': currentLine,
                    'data_line': nextLine,
                    'context_boost': true,
                  },
                ),
              );
            }
          }
        }
      }
    }

    return candidates;
  }

  bool _containsNIKIndicator(String text) {
    final indicators = ['nik', 'ktp', 'nomor', 'no.', 'identitas'];
    return indicators.any((indicator) => text.contains(indicator));
  }

  String _getContext(String text, int start, int end) {
    final contextStart = math.max(0, start - 10);
    final contextEnd = math.min(text.length, end + 10);
    return text.substring(contextStart, contextEnd);
  }

  double _calculateNIKConfidence(
    String nik,
    String context,
    String patternType,
  ) {
    double confidence = 0.0;

    if (_isValidNIKStructure(nik)) confidence += 0.3;

    confidence += _calculateDateConfidence(nik) * 0.2;
    confidence += _calculateProvinceConfidence(nik) * 0.15;
    confidence += _calculateSequenceConfidence(nik) * 0.1;

    confidence += _calculateContextConfidence(context, patternType) * 0.15;

    switch (patternType) {
      case 'labeled_nik':
        confidence += 0.1;
        break;
      case 'exact_16_digits':
        confidence += 0.05;
        break;
      case 'context_based':
        confidence += 0.08;
        break;
    }

    return math.min(1.0, confidence);
  }

  double _calculateDateConfidence(String nik) {
    try {
      final birthDateStr = nik.substring(6, 12);
      int day = int.parse(birthDateStr.substring(0, 2));
      final month = int.parse(birthDateStr.substring(2, 4));
      final year = int.parse(birthDateStr.substring(4, 6));

      if (day > 40) day -= 40;

      if (day < 1 || day > 31) return 0.0;
      if (month < 1 || month > 12) return 0.5;

      final fullYear = year < 50 ? 2000 + year : 1900 + year;
      final age = DateTime.now().year - fullYear;
      if (age < 17 || age > 80) return 0.3;

      return 1.0;
    } catch (e) {
      return 0.0;
    }
  }

  double _calculateProvinceConfidence(String nik) {
    final provinceCode = int.tryParse(nik.substring(0, 2)) ?? 0;

    final validProvinceCodes = [
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      21,
      31,
      32,
      33,
      34,
      35,
      36,
      51,
      52,
      53,
      61,
      62,
      63,
      64,
      65,
      71,
      72,
      73,
      74,
      75,
      76,
      81,
      82,
      91,
      94,
    ];

    return validProvinceCodes.contains(provinceCode) ? 1.0 : 0.0;
  }

  double _calculateSequenceConfidence(String nik) {
    final sequence = nik.substring(12, 16);

    if (sequence == "0000" || sequence == "9999") return 0.3;
    if (RegExp(r'^(\d)\1{3}$').hasMatch(sequence)) return 0.5;

    return 1.0;
  }

  double _calculateContextConfidence(String context, String patternType) {
    double confidence = 0.5;

    final lowerContext = context.toLowerCase();

    if (lowerContext.contains('nik')) confidence += 0.3;
    if (lowerContext.contains('ktp')) confidence += 0.2;
    if (lowerContext.contains('nomor')) confidence += 0.1;

    if (lowerContext.contains('telepon') || lowerContext.contains('hp')) {
      confidence -= 0.3;
    }
    if (lowerContext.contains('rekening') || lowerContext.contains('bank')) {
      confidence -= 0.3;
    }

    return math.max(0.0, math.min(1.0, confidence));
  }

  List<NIKCandidate> _rankAndFilterCandidates(List<NIKCandidate> candidates) {
    final Map<String, NIKCandidate> uniqueCandidates = {};

    for (final candidate in candidates) {
      if (uniqueCandidates.containsKey(candidate.nik)) {
        final existing = uniqueCandidates[candidate.nik]!;
        if (candidate.confidence > existing.confidence) {
          uniqueCandidates[candidate.nik] = candidate;
        }
      } else {
        uniqueCandidates[candidate.nik] = candidate;
      }
    }

    final filtered =
        uniqueCandidates.values
            .where(
              (c) =>
                  c.confidence >= _minConfidenceThreshold &&
                  _isValidNIKStructure(c.nik),
            )
            .toList();

    filtered.sort((a, b) => b.confidence.compareTo(a.confidence));

    return filtered.take(5).toList();
  }

  String _cleanOCRErrors(String text) {
    final corrections = {
      'O': '0',
      'o': '0',
      'Q': '0',
      'D': '0',
      'l': '1',
      'I': '1',
      '|': '1',
      'i': '1',
      'S': '5',
      's': '5',
      'Z': '2',
      'z': '2',
      'G': '6',
      'g': '9',
      'B': '8',
      'b': '6',
      'A': '4',
      'T': '7',
      'h': '4',
    };

    String cleaned = text;
    corrections.forEach((key, value) {
      cleaned = cleaned.replaceAll(key, value);
    });

    return cleaned.replaceAll(RegExp(r'[^\d\s\-\.]'), '');
  }

  String _normalizeNIK(String text) {
    return text
        .replaceAll(RegExp(r'[^0-9oOlIqQbBgGsSzZdD]'), '')
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('Q', '0')
        .replaceAll('l', '1')
        .replaceAll('I', '1')
        .replaceAll('q', '9')
        .replaceAll('b', '6')
        .replaceAll('B', '8')
        .replaceAll('g', '9')
        .replaceAll('G', '6')
        .replaceAll('s', '5')
        .replaceAll('S', '5')
        .replaceAll('z', '2')
        .replaceAll('Z', '2')
        .replaceAll('d', '0')
        .replaceAll('D', '0');
  }

  String _extractNumbersOnly(String text) {
    return _cleanOCRErrors(text).replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isValidNIKStructure(String nik) {
    if (nik.length != 16) return false;
    if (!RegExp(r'^\d{16}$').hasMatch(nik)) return false;

    final provinceCode = int.tryParse(nik.substring(0, 2)) ?? 0;
    final regencyCode = int.tryParse(nik.substring(2, 4)) ?? 0;
    final districtCode = int.tryParse(nik.substring(4, 6)) ?? 0;

    return provinceCode >= 11 &&
        provinceCode <= 94 &&
        regencyCode >= 1 &&
        regencyCode <= 99 &&
        districtCode >= 1 &&
        districtCode <= 99;
  }

  Future<void> selectNIKCandidate(String nik) async {
    final candidate = _nikCandidates.firstWhere(
      (c) => c.nik == nik,
      orElse: () => NIKCandidate(nik: nik, confidence: 0.0, source: 'manual'),
    );

    if (candidate.nik.isNotEmpty) {
      _selectedNik = candidate.nik;
      await _parseNIK(candidate.nik);
      _updateControllers();
      notifyListeners();
    }
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
    _controllers[key]?.text = value;
  }

  void _updateControllers() {
    final mappings = {
      'nik': _ktpData.identificationNumber,
      'name': _ktpData.fullName,
      'placeOfBirth': _ktpData.placeOfBirth,
      'dateOfBirth': _ktpData.dateOfBirth,
      'gender': _ktpData.gender,
      'bloodType': _ktpData.bloodType,
      'hamlet': _ktpData.hamlet,
      'village': _ktpData.village,
      'neighbourhood': _ktpData.neighbourhood,
      'religion': _ktpData.religion,
      'maritalStatus': _ktpData.maritalStatus,
      'job': _ktpData.job,
      'citizenship': _ktpData.citizenship,
      'validUntil': _ktpData.validUntil,
      'province': _ktpData.province,
      'district': _ktpData.district,
      'subDistrict': _ktpData.subDistrict,
      'postalCode': _ktpData.postalCode,
    };

    mappings.forEach((key, value) {
      _controllers[key]?.text = value;
    });
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

      await Future.delayed(const Duration(milliseconds: 300));

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

  Future<void> _cleanupTempFiles() async {
    try {
      if (_processedImage?.existsSync() == true) {
        await _processedImage!.delete();
      }
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
    _ocrCache.clear();
    super.dispose();
  }
}

Future<ProcessedImageResult> _processImageEnhanced(
  ImageProcessingData data,
) async {
  try {
    img.Image? image = img.decodeImage(data.imageBytes);
    if (image == null) {
      return ProcessedImageResult(
        processedPath: data.imagePath,
        success: false,
        error: 'Failed to decode image',
        processingType: data.processingType,
      );
    }

    if (image.width > 1200 || image.height > 1200) {
      final scale = 1200 / math.max(image.width, image.height);
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    }

    img.Image processed = img.grayscale(image);

    processed = img.normalize(processed, min: 0, max: 255);
    processed = img.adjustColor(processed, contrast: 1.4, brightness: 1.05);

    processed = img.convolution(
      processed,
      filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
    );

    final String processedPath = data.imagePath.replaceAll(
      '.jpg',
      '_enhanced.jpg',
    );
    final File processedFile = File(processedPath);
    await processedFile.writeAsBytes(img.encodeJpg(processed, quality: 90));

    return ProcessedImageResult(
      processedPath: processedPath,
      success: true,
      quality: 0.9,
      processingType: data.processingType,
    );
  } catch (e) {
    return ProcessedImageResult(
      processedPath: data.imagePath,
      success: false,
      error: e.toString(),
      processingType: data.processingType,
    );
  }
}

Future<ProcessedImageResult> _processImageAdaptive(
  ImageProcessingData data,
) async {
  try {
    img.Image? image = img.decodeImage(data.imageBytes);
    if (image == null) {
      return ProcessedImageResult(
        processedPath: data.imagePath,
        success: false,
        error: 'Failed to decode image',
        processingType: data.processingType,
      );
    }

    if (image.width > 1200 || image.height > 1200) {
      final scale = 1200 / math.max(image.width, image.height);
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    }

    img.Image processed = img.grayscale(image);

    final threshold = _calculateOtsuThreshold(processed);

    for (int y = 0; y < processed.height; y++) {
      for (int x = 0; x < processed.width; x++) {
        final pixel = processed.getPixel(x, y);
        final gray = img.getLuminance(pixel);
        final newPixel =
            gray > threshold
                ? img.ColorRgb8(255, 255, 255)
                : img.ColorRgb8(0, 0, 0);
        processed.setPixel(x, y, newPixel);
      }
    }

    final String processedPath = data.imagePath.replaceAll(
      '.jpg',
      '_adaptive.jpg',
    );
    final File processedFile = File(processedPath);
    await processedFile.writeAsBytes(img.encodeJpg(processed, quality: 90));

    return ProcessedImageResult(
      processedPath: processedPath,
      success: true,
      quality: 0.8,
      processingType: data.processingType,
    );
  } catch (e) {
    return ProcessedImageResult(
      processedPath: data.imagePath,
      success: false,
      error: e.toString(),
      processingType: data.processingType,
    );
  }
}

int _calculateOtsuThreshold(img.Image image) {
  final histogram = List<int>.filled(256, 0);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final gray = img.getLuminance(pixel).toInt().clamp(0, 255);
      histogram[gray]++;
    }
  }

  final total = image.width * image.height;
  double sum = 0;
  for (int i = 0; i < 256; i++) {
    sum += i * histogram[i];
  }

  double sumB = 0;
  int wB = 0;
  double maxVariance = 0;
  int threshold = 0;

  for (int i = 0; i < 256; i++) {
    wB += histogram[i];
    if (wB == 0) continue;

    final wF = total - wB;
    if (wF == 0) break;

    sumB += i * histogram[i];
    final mB = sumB / wB;
    final mF = (sum - sumB) / wF;

    final variance = wB * wF * (mB - mF) * (mB - mF);

    if (variance > maxVariance) {
      maxVariance = variance;
      threshold = i;
    }
  }

  return threshold;
}
