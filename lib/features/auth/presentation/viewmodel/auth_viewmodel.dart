import 'package:flutter/foundation.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';
import 'package:rijig_mobile/features/auth/service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  AuthState _state = AuthState.initial;
  String _message = '';
  String _errorMessage = '';
  String? _nextStep;
  String? _registrationStatus;
  String? _tokenType;
  bool _isLoggedIn = false;

  String _phone = '';
  String _otp = '';
  String _name = '';
  String _gender = '';
  String _dateOfBirth = '';
  String _placeOfBirth = '';
  String _pin = '';

  AuthState get state => _state;
  String get message => _message;
  String get errorMessage => _errorMessage;
  String? get nextStep => _nextStep;
  String? get registrationStatus => _registrationStatus;
  String? get tokenType => _tokenType;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _state == AuthState.loading;

  String get phone => _phone;
  String get otp => _otp;
  String get name => _name;
  String get gender => _gender;
  String get dateOfBirth => _dateOfBirth;
  String get placeOfBirth => _placeOfBirth;
  String get pin => _pin;

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setOtp(String value) {
    _otp = value;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setDateOfBirth(String value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  void setPlaceOfBirth(String value) {
    _placeOfBirth = value;
    notifyListeners();
  }

  void setPin(String value) {
    _pin = value;
    notifyListeners();
  }

  Future<void> requestOtpRegister() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.requestOtpRegister(_phone);

      if (result.isSuccess) {
        _setState(AuthState.otpSent);
        _message = result.message;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> verifyOtpRegister() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.verifyOtpRegister(_phone, _otp);

      if (result.isSuccess) {
        _setState(AuthState.otpVerified);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> updateProfile() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.updateProfile(
        name: _name,
        phone: _phone,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        placeOfBirth: _placeOfBirth,
      );

      if (result.isSuccess) {
        _setState(AuthState.profileUpdated);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> createPin() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.createPin(_pin);

      if (result.isSuccess) {
        _setState(AuthState.pinCreated);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
        _isLoggedIn = true;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> requestOtpLogin() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.requestOtpLogin(_phone);

      if (result.isSuccess) {
        _setState(AuthState.otpSent);
        _message = result.message;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> verifyOtpLogin() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.verifyOtpLogin(_phone, _otp);

      if (result.isSuccess) {
        _setState(AuthState.otpVerified);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> verifyPin() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.verifyPin(_pin);

      if (result.isSuccess) {
        _setState(AuthState.authenticated);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
        _isLoggedIn = true;
      } else {
        _setState(AuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(AuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> refreshToken() async {
    try {
      final result = await _authService.refreshToken();

      if (result.isSuccess) {
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
  }

  Future<void> logout() async {
    _setState(AuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.logout();
      _reset();
      _message = result.message;
      _setState(AuthState.initial);
    } catch (e) {
      _reset();
      _setState(AuthState.initial);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoggedIn = await _authService.isLoggedIn();

      if (_isLoggedIn) {
        _nextStep = await _authService.getNextStep();
        _registrationStatus = await _authService.getRegistrationStatus();

        if (await _authService.isRegistrationComplete()) {
          _setState(AuthState.authenticated);
        } else {
          _setState(AuthState.otpVerified);
        }
      } else {
        _setState(AuthState.initial);
      }
    } catch (e) {
      _setState(AuthState.initial);
    }
  }

  bool isPhoneValid() {
    return _phone.isNotEmpty &&
        _phone.startsWith('62') &&
        _phone.length >= 10 &&
        _phone.length <= 16;
  }

  bool isOtpValid() {
    return _otp.isNotEmpty && _otp.length == 4;
  }

  bool isProfileValid() {
    return _name.isNotEmpty &&
        _gender.isNotEmpty &&
        _dateOfBirth.isNotEmpty &&
        _placeOfBirth.isNotEmpty;
  }

  bool isPinValid() {
    return _pin.isNotEmpty && _pin.length == 6;
  }

  RegistrationStep getCurrentStep() {
    switch (_nextStep) {
      case 'complete_personal_data':
        return RegistrationStep.completeProfile;
      case 'create_pin':
        return RegistrationStep.createPin;
      case 'verif_pin':
        return RegistrationStep.createPin;
      case 'completed':
        return RegistrationStep.completed;
      default:
        return RegistrationStep.requestOtp;
    }
  }

  bool isRegistrationComplete() {
    return _registrationStatus == 'complete';
  }

  bool hasFullAccess() {
    return _tokenType == 'full';
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _clearMessages() {
    _message = '';
    _errorMessage = '';
  }

  void _reset() {
    _phone = '';
    _otp = '';
    _name = '';
    _gender = '';
    _dateOfBirth = '';
    _placeOfBirth = '';
    _pin = '';
    _nextStep = null;
    _registrationStatus = null;
    _tokenType = null;
    _isLoggedIn = false;
    _clearMessages();
  }

  void clearForm() {
    _reset();
    notifyListeners();
  }
}
