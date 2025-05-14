// import 'package:flutter/material.dart';
// import 'package:rijig_mobile/features/auth/model/userpin_model.dart';

// class PinViewModel extends ChangeNotifier {
//   final PinModel _pinModel = PinModel();
//   bool? pinExists;

//   Future<void> checkPinStatus(String userId) async {
//     try {
//       var response = await _pinModel.checkPinStatus(userId);

//       if (response?.status == 200) {
//         pinExists = true;
//       } else {
//         pinExists = false;
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error checking pin status: $e');
//       pinExists = false;
//       notifyListeners();
//     }
//   }

//   Future<void> createPin(String pin) async {
//     try {
//       var response = await _pinModel.setPin(pin);

//       if (response?.status == 201) {
//         pinExists = true;
//       } else {
//         pinExists = false;
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error creating pin: $e');
//       pinExists = false;
//       notifyListeners();
//     }
//   }

//   Future<void> verifyPin(String pin) async {
//     try {
//       var response = await _pinModel.verifyPin(pin);

//       if (response?.status == 200) {
//         pinExists = true;
//       } else {
//         pinExists = false;
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error verifying pin: $e');
//       pinExists = false;
//       notifyListeners();
//     }
//   }
// }
