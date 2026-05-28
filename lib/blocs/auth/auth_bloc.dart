import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../shared/token_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final TokenStorage tokenStorage;

  // Harap amankan kredensial ini, bisa menggunakan .env
  final String _ownerEmail = 'Nauval@gmail.com';
  final String _ownerPassword = '12345678';

  AuthBloc({required this.authService, required this.tokenStorage})
      : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckStatus(
      AuthCheckStatus event, Emitter<AuthState> emit) async {
    // 1. Cek atau Dapatkan App-Key
    String? appKey = tokenStorage.getAppKey();
    
    if (appKey == null) {
      try {
        // Fetch dari server jika tidak ada
        appKey = await authService.getAppKey(_ownerEmail, _ownerPassword);
        if (appKey != null) {
          await tokenStorage.saveAppKey(appKey);
        } else {
          emit(const AuthFailure('Gagal menginisialisasi sistem: Token null'));
          return;
        }
      } catch (e) {
        emit(AuthFailure('Gagal App-Key: $e'));
        return;
      }
    }

    // 2. Cek JWT Token
    final jwt = tokenStorage.getJwt();
    final role = tokenStorage.getRole() ?? '';

    if (jwt != null && jwt.isNotEmpty) {
      emit(AuthAuthenticated(jwt, role: role));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final user = await authService.loginUser(event.username, event.password);

      if (user.success && user.token != null) {
        // Simpan JWT dan Role
        await tokenStorage.saveJwt(user.token!);
        await tokenStorage.saveRole(user.role ?? '');

        emit(AuthAuthenticated(user.token!, role: user.role ?? ''));
      } else {
        emit(AuthFailure(user.message ?? 'Login gagal, periksa kredensial Anda.'));
      }
    } catch (e) {
      emit(AuthFailure('Terjadi kesalahan sistem: $e'));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await tokenStorage.clearUserTokens();
    emit(AuthUnauthenticated());
  }
}
