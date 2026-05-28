import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCubit extends Cubit<bool> {
  // Default state awal adalah true (tampilkan onboarding)
  OnboardingCubit() : super(true);

  // 1. Fungsi untuk mengecek status dari SharedPreferences saat aplikasi pertama dibuka
  void checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil data 'isFirstTime', jika null (belum pernah diset), berikan nilai default true
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    emit(isFirstTime);
  }

  // 2. Fungsi untuk menandai onboarding sudah selesai
  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // Simpan permanen ke HP
    emit(false); // Update UI via BLoC state menjadi false
  }
}