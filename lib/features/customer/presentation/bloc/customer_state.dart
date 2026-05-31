import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/customer/data/models/customer_model.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final List<CustomerModel> allCustomers;

  const CustomerLoaded(this.customers, this.allCustomers);

  @override
  List<Object?> get props => [customers, allCustomers];
}

class CustomerDetailLoaded extends CustomerState {
  final CustomerModel customer;

  const CustomerDetailLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerOperationLoading extends CustomerState {}

class CustomerOperationSuccess extends CustomerState {
  final String message;

  const CustomerOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
