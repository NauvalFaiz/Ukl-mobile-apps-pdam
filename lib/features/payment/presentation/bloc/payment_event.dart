import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllPayments extends PaymentEvent {}

class FetchMorePayments extends PaymentEvent {}

class VerifyPaymentEvent extends PaymentEvent {
  final int id;
  const VerifyPaymentEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class DeletePaymentEvent extends PaymentEvent {
  final int id;
  const DeletePaymentEvent(this.id);
  @override
  List<Object?> get props => [id];
}