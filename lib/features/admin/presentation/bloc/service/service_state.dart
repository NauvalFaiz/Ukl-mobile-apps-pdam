import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/admin/data/service/models/service_model.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  final List<ServiceModel> allServices; // For filtering

  const ServiceLoaded(this.services, this.allServices);

  @override
  List<Object?> get props => [services, allServices];
}

class ServiceOperationLoading extends ServiceState {}

class ServiceOperationSuccess extends ServiceState {
  final String message;

  const ServiceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
