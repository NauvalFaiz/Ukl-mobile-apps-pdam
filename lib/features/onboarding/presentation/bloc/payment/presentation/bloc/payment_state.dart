import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  const PaymentLoaded(this.payments);

  @override
  List<Object> get props => [payments];
}

class PaymentFailure extends PaymentState {
  final String error;
  const PaymentFailure(this.error);

  @override
  List<Object> get props => [error];
}
