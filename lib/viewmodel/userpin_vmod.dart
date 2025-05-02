import 'package:flutter/material.dart';
import 'package:rijig_mobile/model/userpin_model.dart';

class PinViewModel extends ChangeNotifier {
  final PinModel _pinService = PinModel();

  Future<bool> checkPinStatus() async {
    try {
      return await _pinService.checkPinStatus();
    } catch (e) {
      throw Exception('Error checking PIN status: $e');
    }
  }

  Future<bool> setPin(String userPin) async {
    try {
      return await _pinService.setPin(userPin);
    } catch (e) {
      throw Exception('Error setting PIN: $e');
    }
  }

  Future<bool> verifyPin(String userPin) async {
    try {
      return await _pinService.verifyPin(userPin);
    } catch (e) {
      throw Exception('Error verifying PIN: $e');
    }
  }
}
