import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';
import 'package:uklmobileapps/features/auth/data/datasources/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final TokenStorage tokenStorage;

  final String _ownerEmail = dotenv.env['OWNER_EMAIL'] ?? '';
  final String _ownerPassword = dotenv.env['OWNER_PASSWORD'] ?? '';
  AuthBloc({required this.authService, required this.tokenStorage})
    : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    String? appKey = tokenStorage.getAppKey();

    if (appKey == null) {
      try {
        // Fetch dari server jika tidak ada
        appKey = await authService.getAppKey(_ownerEmail, _ownerPassword);
        if (appKey != null) {
          await tokenStorage.saveAppKey(appKey);
          // PERBAIKAN: Jangan hentikan fungsi di sini, biarkan kode mengalir ke bawah
        } else {
          emit(const AuthFailure('Gagal menginisialisasi sistem: Token null'));
          return;
        }
      } catch (e) {
        emit(AuthFailure('Gagal App-Key: $e'));
        return;
      }
    }

    // 2. Cek JWT Token (Sekarang bagian ini pasti dieksekusi)
    final jwt = tokenStorage.getJwt();
    final role = tokenStorage.getRole() ?? '';

    if (jwt != null && jwt.isNotEmpty) {
      emit(AuthAuthenticated(jwt, role: role));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authService.loginUser(event.username, event.password);

      if (user.success && user.token != null) {
        // Simpan JWT dan Role
        await tokenStorage.saveJwt(user.token!);
        await tokenStorage.saveRole(user.role ?? '');

        emit(AuthAuthenticated(user.token!, role: user.role ?? ''));
      } else {
        emit(
          AuthFailure(user.message ?? 'Login gagal, periksa kredensial Anda.'),
        );
      }
    } catch (e) {
      emit(AuthFailure('Terjadi kesalahan sistem: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenStorage.clearUserTokens();
    emit(AuthUnauthenticated());
  }
}
