import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class UploadKtpScreen extends StatefulWidget {
  const UploadKtpScreen({super.key});

  @override
  State<UploadKtpScreen> createState() => _UploadKtpScreenState();
}

class _UploadKtpScreenState extends State<UploadKtpScreen> {
  File? _ktpImage;
  bool isLoading = false;

  final Map<String, TextEditingController> controllers = {
    "NIK": TextEditingController(),
    "Nama": TextEditingController(),
    "Tempat/Tgl Lahir": TextEditingController(),
    "Alamat": TextEditingController(),
    "RT/RW": TextEditingController(),
    "Kel/Desa": TextEditingController(),
    "Kecamatan": TextEditingController(),
    "Agama": TextEditingController(),
    "Status Perkawinan": TextEditingController(),
    "Pekerjaan": TextEditingController(),
    "Kewarganegaraan": TextEditingController(),
    "Berlaku Hingga": TextEditingController(),
  };

  final Map<String, List<String>> labelSynonyms = {
    "NIK": ["nik"],
    "Nama": ["nama", "nama lengkap"],
    "Tempat/Tgl Lahir": ["tempat/tgl lahir", "tempat lahir", "tgl lahir"],
    "Alamat": ["alamat"],
    "RT/RW": ["rt/rw", "rtrw", "rt rw"],
    "Kel/Desa": ["kelurahan", "desa", "kel/desa"],
    "Kecamatan": ["kecamatan"],
    "Agama": ["agama"],
    "Status Perkawinan": ["status", "status perkawinan", "perkawinan"],
    "Pekerjaan": ["pekerjaan"],
    "Kewarganegaraan": ["kewarganegaraan", "warga negara"],
    "Berlaku Hingga": ["berlaku", "berlaku hingga"],
  };

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
        _ktpImage = File(pickedFile.path);
      });
      await _processImageWithEnhancements(File(pickedFile.path));
      setState(() => isLoading = false);
    }
  }

  Future<void> _processImageWithEnhancements(File imageFile) async {
    final rawBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(rawBytes);
    if (originalImage == null) return;

    // Enhance image: grayscale + auto rotate + thresholding
    var processedImage = img.grayscale(originalImage);
    if (processedImage.width > processedImage.height) {
      processedImage = img.copyRotate(processedImage, angle: -90);
    }
    // processedImage = img.threshold(processedImage, threshold: 128);

    final tempDir = await getTemporaryDirectory();
    final enhancedPath = '${tempDir.path}/enhanced_ktp.jpg';
    final enhancedFile = File(enhancedPath)
      ..writeAsBytesSync(img.encodeJpg(processedImage));

    final inputImage = InputImage.fromFile(enhancedFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    await textRecognizer.close();

    final lines = recognizedText.text.split('\n');
    debugPrint("[OCR Result]\n${recognizedText.text}");

    setState(() {
      for (var key in controllers.keys) {
        final value = _extractMultilineValue(key, lines);
        controllers[key]?.text = value;
      }
    });
  }

  String _extractMultilineValue(String key, List<String> lines) {
    final List<String> keywords = labelSynonyms[key] ?? [key];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      for (final kw in keywords) {
        if (line.contains(kw.toLowerCase())) {
          if (lines[i].contains(":")) {
            return lines[i].split(":").last.trim();
          } else if (i + 1 < lines.length) {
            return lines[i + 1].trim();
          }
        }
      }
    }
    return '';
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text("Upload KTP"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ktpImage != null
                  ? Image.file(_ktpImage!, height: 200)
                  : Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(child: Text("Belum ada gambar KTP")),
                  ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : CardButtonOne(
                    textButton: "Upload Foto KTP",
                    fontSized: 16,
                    colorText: whiteColor,
                    color: primaryColor,
                    borderRadius: 10,
                    horizontal: double.infinity,
                    vertical: 50,
                    onTap: _pickImage,
                    usingRow: false,
                  ),
              const SizedBox(height: 30),
              for (var key in controllers.keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    decoration: InputDecoration(labelText: key),
                    controller: controllers[key],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
