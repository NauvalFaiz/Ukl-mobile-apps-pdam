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
    // Simpan state loaded saat ini agar bisa dikembalikan jika error
    final previousState = state is AdminProfileLoaded ? state as AdminProfileLoaded : null;

    if (previousState != null) {
      emit(AdminProfileUpdating(
        id: previousState.id,
        name: previousState.name,
        phone: previousState.phone,
      ));
    } else {
      emit(AdminProfileLoading());
    }

    try {
      final Map<String, dynamic> payload = {
        'name': event.name,
        'phone': event.phone,
        'username': event.username,
      };

      if (event.password != null && event.password!.isNotEmpty) {
        payload['password'] = event.password;
      }

      debugPrint('Update payload: $payload');
      await adminService.updateAdminProfile(event.id, payload);
      emit(const AdminProfileUpdateSuccess('Profil berhasil diperbarui'));

      // Fetch data terbaru dari server
      add(FetchAdminProfileEvent());
    } catch (e) {
      debugPrint('UpdateAdminProfile error: $e');

      // Kembalikan ke state loaded sebelumnya agar tombol edit tidak terkunci
      if (previousState != null) {
        emit(previousState);
      }

      // Tampilkan pesan error yang bersih (hilangkan prefix "Exception: ")
      final rawMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AdminProfileError(rawMsg));

      // Jika state sebelumnya tidak ada, fetch ulang dari server
      if (previousState == null) {
        add(FetchAdminProfileEvent());
      }
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