import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class FetchPayments extends PaymentEvent {}
class FetchCustomerPayments extends PaymentEvent {}
