import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllCustomers extends CustomerEvent {}

class SearchCustomerByName extends CustomerEvent {
  final String query;

  const SearchCustomerByName(this.query);

  @override
  List<Object?> get props => [query];
}

class FetchCustomerById extends CustomerEvent {
  final int id;

  const FetchCustomerById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateCustomerEvent extends CustomerEvent {
  final Map<String, dynamic> data;

  const CreateCustomerEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateCustomerEvent extends CustomerEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateCustomerEvent(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteCustomerEvent extends CustomerEvent {
  final int id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}
