import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/customer/data/models/customer_model.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

abstract class CustomerMeState extends Equatable {
  const CustomerMeState();
  @override
  List<Object?> get props => [];
}

class CustomerMeInitial extends CustomerMeState {}
class CustomerMeLoading extends CustomerMeState {}

class CustomerDashboardLoaded extends CustomerMeState {
  final CustomerModel profile;
  final List<BillModel> bills;
  const CustomerDashboardLoaded(this.profile, this.bills);
  @override
  List<Object?> get props => [profile, bills];
}

class CustomerBillsLoaded extends CustomerMeState {
  final List<BillModel> bills;
  const CustomerBillsLoaded(this.bills);
  @override
  List<Object?> get props => [bills];
}

class CustomerPaymentsLoaded extends CustomerMeState {
  final List<PaymentModel> payments;
  const CustomerPaymentsLoaded(this.payments);
  @override
  List<Object?> get props => [payments];
}

class CustomerMeOperationLoading extends CustomerMeState {}
class CustomerMeOperationSuccess extends CustomerMeState {
  final String message;
  const CustomerMeOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerMeError extends CustomerMeState {
  final String message;
  const CustomerMeError(this.message);
  @override
  List<Object?> get props => [message];
}
