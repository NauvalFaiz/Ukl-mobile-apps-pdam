import 'package:equatable/equatable.dart';

abstract class AdminProfileEvent extends Equatable {
  const AdminProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminProfileEvent extends AdminProfileEvent {}

class UpdateAdminProfileEvent extends AdminProfileEvent {
  final int id;
  final String name;
  final String phone;
  final String username; // Ditambahkan field username
  final String? password;

  const UpdateAdminProfileEvent({
    required this.id,
    required this.name,
    required this.phone,
    required this.username,
    this.password,
  });

  @override
  List<Object?> get props => [id, name, phone, username, password];
}

class DeleteAdminProfileEvent extends AdminProfileEvent {
  final int id;

  const DeleteAdminProfileEvent({required this.id});

  @override
  List<Object?> get props => [id];
}