import 'package:equatable/equatable.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllServices extends ServiceEvent {}

class SearchServiceByName extends ServiceEvent {
  final String query;

  const SearchServiceByName(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateServiceEvent extends ServiceEvent {
  final Map<String, dynamic> data;

  const CreateServiceEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateServiceEvent extends ServiceEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateServiceEvent(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteServiceEvent extends ServiceEvent {
  final int id;

  const DeleteServiceEvent(this.id);

  @override
  List<Object?> get props => [id];
}
