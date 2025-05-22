import 'package:rijig_mobile/features/launch/model/onboard_model.dart';

class OnboardingData {
  static List<OnboardingModel> items = [
    OnboardingModel(
      imagePath: "assets/image/onboard_first.png",
      headline: 'Sampahmu, Cuanmu',
      description:
          'Jual sampah dari rumah tanpa ribet. Bisa dapet duit, bisa bantu lingkungan juga!',
    ),
    OnboardingModel(
      imagePath: "assets/image/waiting_oboard_sec.png",
      headline: 'Pilih Pengepul, Duduk Manis',
      description:
          'Tinggal pilih pengepul terdekat, mereka yang datang ke kamu. Praktis banget, kan?',
    ),
    OnboardingModel(
      imagePath: "assets/image/onboard_third.png",
      headline: 'Ayo, Kita Jaga Bumi Bareng',
      description:
          'Satu langkah kecil bisa bikin perubahan besar. Yuk mulai sekarang — lanjut masuk dulu, ya!',
    ),
  ];
}
