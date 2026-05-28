import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/admin_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_state.dart';

class AdminProfileBloc extends Bloc<AdminProfileEvent, AdminProfileState> {
  final AdminService adminService;

  AdminProfileBloc({required this.adminService}) : super(AdminProfileInitial()) {
    on<FetchAdminProfileEvent>(_onFetchAdminProfile);
    on<UpdateAdminProfileEvent>(_onUpdateAdminProfile);
    on<DeleteAdminProfileEvent>(_onDeleteAdminProfile);
  }

  Future<void> _onFetchAdminProfile(FetchAdminProfileEvent event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileLoading());
    try {
      final response = await adminService.getAdminProfile();
      if (response['data'] != null) {
        final data = response['data'];
        final user = data['user'];
        emit(AdminProfileLoaded(
          id: data['id'],
          name: data['name'] ?? '',
          phone: data['phone'] ?? '',
          username: user != null ? (user['username'] ?? '') : '',
          role: user != null ? (user['role'] ?? '') : '',
        ));
      } else {
        emit(const AdminProfileError('Data profil tidak ditemukan.'));
      }
    } catch (e) {
      debugPrint('FetchAdminProfile error: $e');
      emit(AdminProfileError('$e'));
    }
  }

  Future<void> _onUpdateAdminProfile(UpdateAdminProfileEvent event, Emitter<AdminProfileState> emit) async {
    AdminProfileLoaded? currentState;
    if (state is AdminProfileLoaded) {
      currentState = state as AdminProfileLoaded;
      emit(AdminProfileUpdating(id: currentState.id, name: currentState.name, phone: currentState.phone));
    } else {
      emit(AdminProfileLoading());
    }

    try {
      // Menyusun data payload secara dinamis sesuai kebutuhan API backend PDAM
      final Map<String, dynamic> payload = {
        'name': event.name,
        'phone': event.phone,
        'username': event.username, // Mengirimkan username baru ke backend
      };

      if (event.password != null && event.password!.isNotEmpty) {
        payload['password'] = event.password;
      }

      debugPrint('Update payload: $payload');
      await adminService.updateAdminProfile(event.id, payload);
      emit(const AdminProfileUpdateSuccess('Profil berhasil diperbarui'));
      
      // Ambil data profil terbaru dari server setelah berhasil update
      add(FetchAdminProfileEvent());
    } catch (e) {
      debugPrint('UpdateAdminProfile error: $e');
      emit(AdminProfileError('$e'));
      add(FetchAdminProfileEvent());
    }
  }

  Future<void> _onDeleteAdminProfile(DeleteAdminProfileEvent event, Emitter<AdminProfileState> emit) async {
    emit(AdminProfileDeleting());
    try {
      await adminService.deleteAdminProfile(event.id);
      emit(AdminProfileDeleteSuccess());
    } catch (e) {
      debugPrint('DeleteAdminProfile error: $e');
      emit(AdminProfileError('$e'));
      add(FetchAdminProfileEvent());
    }
  }
}