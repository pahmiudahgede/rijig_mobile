class Validators {
  static const List<String> _validPhonePrefixes = [
    '62811',
    '62812',
    '62813',
    '62821',
    '62822',
    '62823',
    '62851',
    '62852',
    '62853',

    '62814',
    '62815',
    '62816',
    '62855',
    '62856',
    '62857',
    '62858',

    '62817',
    '62818',
    '62819',
    '62859',
    '62877',
    '62878',

    '62895',
    '62896',
    '62897',
    '62898',
    '62899',

    '62881',
    '62882',
    '62883',
    '62884',
    '62885',
    '62886',
    '62887',
    '62888',
    '62889',
  ];

  static const List<String> _weakPins = [
    '123456',
    '654321',
    '111111',
    '000000',
    '123123',
    '121212',
    '101010',
    '020202',
    '030303',
    '040404',
    '050505',
    '060606',
    '070707',
    '080808',
    '090909',
    '112233',
    '223344',
    '334455',
    '445566',
    '556677',
    '667788',
    '778899',
    '998877',
    '887766',
    '776655',
  ];

  static const List<String> _validGenders = [
    'laki-laki',
    'perempuan',
    'l',
    'p',
    'male',
    'female',
  ];

  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (!cleanPhone.startsWith('62')) return false;
    if (cleanPhone.length < 10 || cleanPhone.length > 16) return false;

    final hasValidPrefix = _validPhonePrefixes.any(
      (prefix) => cleanPhone.startsWith(prefix),
    );
    if (hasValidPrefix) return true;

    return cleanPhone.startsWith('628') &&
        cleanPhone.length >= 11 &&
        cleanPhone.length <= 13;
  }

  static String? validatePhone(String? phone) {
    if (phone?.isEmpty ?? true) {
      return 'Nomor telepon tidak boleh kosong';
    }

    if (!isValidPhone(phone!)) {
      return 'Format nomor telepon tidak valid. Gunakan format 628xxxxxxxxx';
    }

    return null;
  }

  static bool isValidOtp(String otp) {
    return otp.isNotEmpty &&
        otp.length == 4 &&
        RegExp(r'^\d{4}$').hasMatch(otp);
  }

  static String? validateOtp(String? otp) {
    if (otp?.isEmpty ?? true) {
      return 'Kode OTP tidak boleh kosong';
    }

    if (!isValidOtp(otp!)) {
      return 'Kode OTP harus 4 digit angka';
    }

    return null;
  }

  static bool isValidPin(String pin) {
    if (pin.isEmpty || pin.length != 6) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) return false;

    return !_isWeakPin(pin);
  }

  static bool _isWeakPin(String pin) {
    if (_weakPins.contains(pin)) return true;

    if (RegExp(r'^(\d)\1{5}$').hasMatch(pin)) return true;

    if (RegExp(r'^(\d)(\d)\1\2\1\2$').hasMatch(pin)) return true;

    if (_isAscendingSequence(pin)) return true;

    if (_isDescendingSequence(pin)) return true;

    return false;
  }

  static bool _isAscendingSequence(String pin) {
    for (int i = 1; i < pin.length; i++) {
      final current = int.parse(pin[i]);
      final previous = int.parse(pin[i - 1]);

      if (current != previous + 1) {
        return false;
      }
    }
    return true;
  }

  static bool _isDescendingSequence(String pin) {
    for (int i = 1; i < pin.length; i++) {
      final current = int.parse(pin[i]);
      final previous = int.parse(pin[i - 1]);

      if (current != previous - 1) {
        return false;
      }
    }
    return true;
  }

  static String? validatePin(String? pin) {
    if (pin?.isEmpty ?? true) {
      return 'PIN tidak boleh kosong';
    }

    if (pin!.length != 6) {
      return 'PIN harus 6 digit';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'PIN hanya boleh berisi angka';
    }

    if (_isWeakPin(pin)) {
      return 'PIN terlalu lemah. Hindari urutan angka, angka yang sama, atau pola yang mudah ditebak';
    }

    return null;
  }

  static String? validateName(String? name) {
    if (name?.isEmpty ?? true) {
      return 'Nama tidak boleh kosong';
    }

    final trimmedName = name!.trim();

    if (trimmedName.length < 2) {
      return 'Nama minimal 2 karakter';
    }

    if (trimmedName.length > 50) {
      return 'Nama maksimal 50 karakter';
    }

    if (!RegExp(r"^[a-zA-Z\s\.\'-]+$").hasMatch(trimmedName)) {
      return 'Nama hanya boleh berisi huruf, spasi, titik, dan tanda petik';
    }

    if (RegExp(r'\s{2,}').hasMatch(trimmedName)) {
      return 'Nama tidak boleh memiliki spasi berturut-turut';
    }

    if (trimmedName != trimmedName.trim()) {
      return 'Nama tidak boleh dimulai atau diakhiri dengan spasi';
    }

    return null;
  }

  static String? validateDate(String? date) {
    if (date?.isEmpty ?? true) {
      return 'Tanggal tidak boleh kosong';
    }

    if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date!)) {
      return 'Format tanggal harus DD-MM-YYYY';
    }

    try {
      final parts = date.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (month < 1 || month > 12) {
        return 'Bulan tidak valid (1-12)';
      }

      if (day < 1 || day > 31) {
        return 'Tanggal tidak valid (1-31)';
      }

      final parsedDate = DateTime(year, month, day);

      if (parsedDate.day != day ||
          parsedDate.month != month ||
          parsedDate.year != year) {
        return 'Tanggal tidak valid untuk bulan tersebut';
      }

      final now = DateTime.now();
      final minDate = DateTime(1900);

      if (parsedDate.isAfter(now)) {
        return 'Tanggal tidak boleh di masa depan';
      }

      if (parsedDate.isBefore(minDate)) {
        return 'Tanggal tidak valid (minimum tahun 1900)';
      }

      final minAge = DateTime(now.year - 17, now.month, now.day);
      if (parsedDate.isAfter(minAge)) {
        return 'Usia minimal 17 tahun';
      }
    } catch (e) {
      return 'Format tanggal tidak valid';
    }

    return null;
  }

  static String? validatePlace(String? place) {
    if (place?.isEmpty ?? true) {
      return 'Tempat tidak boleh kosong';
    }

    final trimmedPlace = place!.trim();

    if (trimmedPlace.length < 2) {
      return 'Tempat minimal 2 karakter';
    }

    if (trimmedPlace.length > 30) {
      return 'Tempat maksimal 30 karakter';
    }

    if (!RegExp(r'^[a-zA-Z0-9\s\.\,\-]+$').hasMatch(trimmedPlace)) {
      return 'Tempat hanya boleh berisi huruf, angka, spasi, titik, koma, dan tanda hubung';
    }

    return null;
  }

  static String? validateGender(String? gender) {
    if (gender?.isEmpty ?? true) {
      return 'Jenis kelamin harus dipilih';
    }

    if (!_validGenders.contains(gender!.toLowerCase())) {
      return 'Jenis kelamin tidak valid';
    }

    return null;
  }

  static String? validateEmail(String? email) {
    if (email?.isEmpty ?? true) {
      return 'Email tidak boleh kosong';
    }

    final trimmedEmail = email!.trim().toLowerCase();

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmedEmail)) {
      return 'Format email tidak valid';
    }

    if (trimmedEmail.length > 254) {
      return 'Email terlalu panjang (maksimal 254 karakter)';
    }

    return null;
  }

  static String? validateAddress(String? address) {
    if (address?.isEmpty ?? true) {
      return 'Alamat tidak boleh kosong';
    }

    final trimmedAddress = address!.trim();

    if (trimmedAddress.length < 10) {
      return 'Alamat minimal 10 karakter';
    }

    if (trimmedAddress.length > 200) {
      return 'Alamat maksimal 200 karakter';
    }

    return null;
  }
}
