import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/services/pengepul_auth_service.dart';

class PengepulAuthViewModel extends ChangeNotifier {
  final PengepulAuthService _authService;

  PengepulAuthViewModel(this._authService);

  PengepulAuthState _state = PengepulAuthState.initial;
  String _message = '';
  String _errorMessage = '';
  String? _nextStep;
  String? _registrationStatus;
  String? _tokenType;
  String? _userRole;
  bool _isLoggedIn = false;

  String _phone = '';
  String _otp = '';
  String _pin = '';

  String _identificationNumber = '';
  String _fullname = '';
  String _placeOfBirth = '';
  String _dateOfBirth = '';
  String _gender = '';
  String _bloodType = '';
  String _province = '';
  String _district = '';
  String _subdistrict = '';
  String _hamlet = '';
  String _village = '';
  String _neighbourhood = '';
  String _postalCode = '';
  String _religion = '';
  String _maritalStatus = '';
  String _job = '';
  String _citizenship = '';
  String _validUntil = '';
  File? _cardPhoto;

  Timer? _approvalTimer;
  bool _isPollingApproval = false;
  int _pollingAttempts = 0;
  static const int maxPollingAttempts = 120;

  PengepulAuthState get state => _state;
  String get message => _message;
  String get errorMessage => _errorMessage;
  String? get nextStep => _nextStep;
  String? get registrationStatus => _registrationStatus;
  String? get tokenType => _tokenType;
  String? get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _state == PengepulAuthState.loading;
  bool get isPollingApproval => _isPollingApproval;
  int get pollingAttempts => _pollingAttempts;

  String get phone => _phone;
  String get otp => _otp;
  String get pin => _pin;

  String get identificationNumber => _identificationNumber;
  String get fullname => _fullname;
  String get placeOfBirth => _placeOfBirth;
  String get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  String get bloodType => _bloodType;
  String get province => _province;
  String get district => _district;
  String get subdistrict => _subdistrict;
  String get hamlet => _hamlet;
  String get village => _village;
  String get neighbourhood => _neighbourhood;
  String get postalCode => _postalCode;
  String get religion => _religion;
  String get maritalStatus => _maritalStatus;
  String get job => _job;
  String get citizenship => _citizenship;
  String get validUntil => _validUntil;
  File? get cardPhoto => _cardPhoto;

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setOtp(String value) {
    _otp = value;
    notifyListeners();
  }

  void setPin(String value) {
    _pin = value;
    notifyListeners();
  }

  void setIdentificationNumber(String value) {
    _identificationNumber = value;
    notifyListeners();
  }

  void setFullname(String value) {
    _fullname = value;
    notifyListeners();
  }

  void setPlaceOfBirth(String value) {
    _placeOfBirth = value;
    notifyListeners();
  }

  void setDateOfBirth(String value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setBloodType(String value) {
    _bloodType = value;
    notifyListeners();
  }

  void setProvince(String value) {
    _province = value;
    notifyListeners();
  }

  void setDistrict(String value) {
    _district = value;
    notifyListeners();
  }

  void setSubdistrict(String value) {
    _subdistrict = value;
    notifyListeners();
  }

  void setHamlet(String value) {
    _hamlet = value;
    notifyListeners();
  }

  void setVillage(String value) {
    _village = value;
    notifyListeners();
  }

  void setNeighbourhood(String value) {
    _neighbourhood = value;
    notifyListeners();
  }

  void setPostalCode(String value) {
    _postalCode = value;
    notifyListeners();
  }

  void setReligion(String value) {
    _religion = value;
    notifyListeners();
  }

  void setMaritalStatus(String value) {
    _maritalStatus = value;
    notifyListeners();
  }

  void setJob(String value) {
    _job = value;
    notifyListeners();
  }

  void setCitizenship(String value) {
    _citizenship = value;
    notifyListeners();
  }

  void setValidUntil(String value) {
    _validUntil = value;
    notifyListeners();
  }

  void setCardPhoto(File? file) {
    _cardPhoto = file;
    notifyListeners();
  }

  Future<void> requestOtpRegister() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.requestOtpRegister(_phone);

      if (result.isSuccess) {
        _setState(PengepulAuthState.otpSent);
        _message = result.message;
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> verifyOtpRegister() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.verifyOtpRegister(_phone, _otp);

      if (result.isSuccess) {
        _setState(PengepulAuthState.otpVerified);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> uploadKtp() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final ktpData = KtpIdentity(
        identificationNumber: _identificationNumber,
        fullname: _fullname,
        placeOfBirth: _placeOfBirth,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        bloodType: _bloodType,
        province: _province,
        district: _district,
        subdistrict: _subdistrict,
        hamlet: _hamlet,
        village: _village,
        neighbourhood: _neighbourhood,
        postalCode: _postalCode,
        religion: _religion,
        maritalStatus: _maritalStatus,
        job: _job,
        citizenship: _citizenship,
        validUntil: _validUntil,
        cardPhoto: _cardPhoto!,
      );

      final result = await _authService.uploadKtp(ktpData);

      if (result.isSuccess) {
        _setState(PengepulAuthState.ktpUploaded);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;

        await Future.delayed(const Duration(milliseconds: 200));

        _startApprovalPolling();
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> checkApprovalStatus() async {
    try {
      if (_state == PengepulAuthState.approved ||
          _state == PengepulAuthState.rejected ||
          _state == PengepulAuthState.authenticated) {
        debugPrint('Skipping approval check - already in final state: $_state');
        _stopApprovalPolling();
        return;
      }

      debugPrint('Checking approval status...');
      final result = await _authService.checkApprovalStatus();

      if (result.isSuccess) {
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;

        debugPrint('Approval status response: $_registrationStatus');

        if (_registrationStatus == 'approved') {
          debugPrint('✅ APPROVED! Stopping polling...');
          _setState(PengepulAuthState.approved);
          _message = result.message;
          _stopApprovalPolling();
        } else if (_registrationStatus == 'awaiting_approval') {
          if (_state != PengepulAuthState.awaitingApproval) {
            debugPrint('Setting state to awaiting approval');
            _setState(PengepulAuthState.awaitingApproval);
          }
        } else if (_registrationStatus == 'rejected') {
          debugPrint('❌ REJECTED! Stopping polling...');
          _setState(PengepulAuthState.rejected);
          _errorMessage = result.message;
          _stopApprovalPolling();
        }

        notifyListeners();
      } else {
        debugPrint('Approval check failed: ${result.message}');
      }
    } catch (e) {
      debugPrint('Approval check error: $e');
    }
  }

  Future<void> createPin() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.createPin(_pin);

      if (result.isSuccess) {
        _setState(PengepulAuthState.pinCreated);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
        _isLoggedIn = true;
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> requestOtpLogin() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.requestOtpLogin(_phone);

      if (result.isSuccess) {
        _setState(PengepulAuthState.otpSent);
        _message = result.message;
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> verifyOtpLogin() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.verifyOtpLogin(_phone, _otp);

      if (result.isSuccess) {
        _setState(PengepulAuthState.otpVerified);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> verifyPin() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();

    try {
      final result = await _authService.verifyPin(_pin);

      if (result.isSuccess) {
        _setState(PengepulAuthState.authenticated);
        _message = result.message;
        _nextStep = result.nextStep;
        _registrationStatus = result.registrationStatus;
        _tokenType = result.tokenType;
        _isLoggedIn = true;
      } else {
        _setState(PengepulAuthState.error);
        _errorMessage = result.message;
      }
    } catch (e) {
      _setState(PengepulAuthState.error);
      _errorMessage = e.toString();
    }
  }

  Future<void> logout() async {
    _setState(PengepulAuthState.loading);
    _clearMessages();
    _stopApprovalPolling();

    try {
      final result = await _authService.logout();
      _reset();
      _message = result.message;
      _setState(PengepulAuthState.initial);
    } catch (e) {
      _reset();
      _setState(PengepulAuthState.initial);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      debugPrint('=== CHECKING PENGEPUL AUTH STATUS ===');

      _isLoggedIn = await _authService.isLoggedIn();
      debugPrint('isLoggedIn from service: $_isLoggedIn');

      if (_isLoggedIn) {
        _nextStep = await _authService.getNextStep();
        _registrationStatus = await _authService.getRegistrationStatus();
        _userRole = await _authService.getUserRole();

        debugPrint('nextStep: $_nextStep');
        debugPrint('registrationStatus: $_registrationStatus');
        debugPrint('userRole: $_userRole');

        if (await _authService.isRegistrationComplete()) {
          debugPrint('Registration is complete, setting authenticated state');
          _setState(PengepulAuthState.authenticated);
        } else {
          debugPrint(
            'Registration incomplete, setting state based on next step',
          );
          _setStateBasedOnNextStep();
        }
      } else {
        debugPrint('User not logged in, setting initial state');
        _setState(PengepulAuthState.initial);
      }
    } catch (e) {
      debugPrint('Check auth status error: $e');
      _setState(PengepulAuthState.initial);
      _isLoggedIn = false;
    }
  }

  void _startApprovalPolling() {
    if (_isPollingApproval) {
      debugPrint('Polling already running, skipping start');
      return;
    }

    debugPrint('Starting approval polling...');
    _isPollingApproval = true;
    _pollingAttempts = 0;

    _stopApprovalPolling();

    _approvalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _pollingAttempts++;

      debugPrint('Polling attempt: $_pollingAttempts, State: $_state');

      if (_state == PengepulAuthState.approved ||
          _state == PengepulAuthState.rejected ||
          _state == PengepulAuthState.authenticated) {
        debugPrint('Stopping polling due to final state: $_state');
        _stopApprovalPolling();
        return;
      }

      if (_pollingAttempts >= maxPollingAttempts) {
        debugPrint('Polling timeout reached');
        _stopApprovalPolling();
        _setState(PengepulAuthState.error);
        _errorMessage = 'Approval check timeout. Please try again later.';
        return;
      }

      checkApprovalStatus();
    });

    checkApprovalStatus();
  }

  void _stopApprovalPolling() {
    debugPrint('Stopping approval polling...');
    _approvalTimer?.cancel();
    _approvalTimer = null;
    _isPollingApproval = false;
    _pollingAttempts = 0;
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

  bool isPinValid() {
    return _pin.isNotEmpty && _pin.length == 6;
  }

  bool isKtpDataValid() {
    return _identificationNumber.isNotEmpty &&
        _fullname.isNotEmpty &&
        _placeOfBirth.isNotEmpty &&
        _dateOfBirth.isNotEmpty &&
        _gender.isNotEmpty &&
        _bloodType.isNotEmpty &&
        _province.isNotEmpty &&
        _district.isNotEmpty &&
        _subdistrict.isNotEmpty &&
        _hamlet.isNotEmpty &&
        _village.isNotEmpty &&
        _neighbourhood.isNotEmpty &&
        _postalCode.isNotEmpty &&
        _religion.isNotEmpty &&
        _maritalStatus.isNotEmpty &&
        _job.isNotEmpty &&
        _citizenship.isNotEmpty &&
        _validUntil.isNotEmpty &&
        _cardPhoto != null;
  }

  PengepulRegistrationStep getCurrentStep() {
    switch (_nextStep) {
      case 'upload_ktp':
        return PengepulRegistrationStep.uploadKtp;
      case 'awaiting_admin_approval':
        return PengepulRegistrationStep.awaitingApproval;
      case 'create_pin':
        return PengepulRegistrationStep.createPin;
      case 'verif_pin':
        return PengepulRegistrationStep.createPin;
      case 'completed':
        return PengepulRegistrationStep.completed;
      default:
        return PengepulRegistrationStep.requestOtp;
    }
  }

  bool isRegistrationComplete() {
    return _registrationStatus == 'complete';
  }

  bool isAwaitingApproval() {
    return _registrationStatus == 'awaiting_approval';
  }

  bool isApproved() {
    return _registrationStatus == 'approved';
  }

  bool hasFullAccess() {
    return _tokenType == 'full';
  }

  void _setState(PengepulAuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setStateBasedOnNextStep() {
    switch (_nextStep) {
      case 'upload_ktp':
        _setState(PengepulAuthState.otpVerified);
        break;
      case 'awaiting_admin_approval':
        _setState(PengepulAuthState.awaitingApproval);

        if (_registrationStatus == 'awaiting_approval') {
          debugPrint('Auto-resuming approval polling');
          _startApprovalPolling();
        } else if (_registrationStatus == 'approved') {
          debugPrint('Already approved, no need to poll');
          _setState(PengepulAuthState.approved);
        }
        break;
      case 'create_pin':
        _setState(PengepulAuthState.approved);
        break;
      case 'verif_pin':
        _setState(PengepulAuthState.otpVerified);
        break;
      default:
        _setState(PengepulAuthState.otpVerified);
    }
  }

  void _clearMessages() {
    _message = '';
    _errorMessage = '';
  }

  void _reset() {
    _phone = '';
    _otp = '';
    _pin = '';
    _identificationNumber = '';
    _fullname = '';
    _placeOfBirth = '';
    _dateOfBirth = '';
    _gender = '';
    _bloodType = '';
    _province = '';
    _district = '';
    _subdistrict = '';
    _hamlet = '';
    _village = '';
    _neighbourhood = '';
    _postalCode = '';
    _religion = '';
    _maritalStatus = '';
    _job = '';
    _citizenship = '';
    _validUntil = '';
    _cardPhoto = null;
    _nextStep = null;
    _registrationStatus = null;
    _tokenType = null;
    _userRole = null;
    _isLoggedIn = false;
    _stopApprovalPolling();
    _clearMessages();
  }

  void clearForm() {
    _reset();
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🧹 Disposing PengepulAuthViewModel');
    _stopApprovalPolling();
    super.dispose();
  }
}
