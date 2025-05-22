import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class UploadKtpScreen extends StatefulWidget {
  const UploadKtpScreen({super.key});

  @override
  State<UploadKtpScreen> createState() => _UploadKtpScreenState();
}

class _UploadKtpScreenState extends State<UploadKtpScreen> {
  File? _ktpImage;
  String nik = '';
  String nama = '';
  String alamat = '';
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
        _ktpImage = File(pickedFile.path);
      });
      await _processImage(File(pickedFile.path));
      setState(() => isLoading = false);
    }
  }
  //dari kode ini 

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final text = recognizedText.text;
    setState(() {
      nik = _extractValue("NIK", text);
      nama = _extractValue("Nama", text);
      alamat = _extractValue("Alamat", text);
    });
  }

  // terdapat error 'textRecognizer' is deprecated and shouldn't be used. Use [google_mlkit_text_recognition] plugin instead of [google_ml_kit].
// Try replacing the use of the deprecated member with the replacement.dartdeprecated_member_use
// (deprecated) TextRecognizer textRecognizer({dynamic script = TextRecognitionScript.latin})
// Type: TextRecognizer Function({dynamic script})

// package:google_ml_kit/src/vision.dart

// Return an instance of [TextRecognizer].

  String _extractValue(String key, String fullText) {
    final regex = RegExp('${key}s*[:s]?s*(.*)', caseSensitive: false);
    final match = regex.firstMatch(fullText);
    return match?.group(1)?.split("\n").first.trim() ?? '';
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
              TextField(
                decoration: const InputDecoration(labelText: 'NIK'),
                controller: TextEditingController(text: nik),
                onChanged: (val) => nik = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Nama'),
                controller: TextEditingController(text: nama),
                onChanged: (val) => nama = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Alamat'),
                controller: TextEditingController(text: alamat),
                onChanged: (val) => alamat = val,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
