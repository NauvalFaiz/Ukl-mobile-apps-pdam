import 'package:equatable/equatable.dart';

abstract class AdminProfileState extends Equatable {
  const AdminProfileState();

  @override
  List<Object?> get props => [];
}

class AdminProfileInitial extends AdminProfileState {}

class AdminProfileLoading extends AdminProfileState {}

class AdminProfileLoaded extends AdminProfileState {
  final int id;
  final String name;
  final String phone;
  final String username;
  final String role;

  const AdminProfileLoaded({required this.id, required this.name, required this.phone, required this.username, required this.role});

  @override
  List<Object?> get props => [id, name, phone, username, role];
}

class AdminProfileUpdating extends AdminProfileState {
  final int id;
  final String name;
  final String phone;

  const AdminProfileUpdating({required this.id, required this.name, required this.phone});

  @override
  List<Object?> get props => [id, name, phone];
}

class AdminProfileUpdateSuccess extends AdminProfileState {
  final String message;
  const AdminProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminProfileError extends AdminProfileState {
  final String message;
  const AdminProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminProfileDeleting extends AdminProfileState {}

class AdminProfileDeleteSuccess extends AdminProfileState {}
