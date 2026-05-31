import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  const PaymentLoaded(this.payments);
  @override
  List<Object?> get props => [payments];
}

class PaymentOperationLoading extends PaymentState {}

class PaymentOperationSuccess extends PaymentState {
  final String message;
  const PaymentOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}
