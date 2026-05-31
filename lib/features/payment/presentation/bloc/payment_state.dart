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
  final int currentPage;
  final bool hasReachedMax;

  const PaymentLoaded(
    this.payments, {
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  PaymentLoaded copyWith({
    List<PaymentModel>? payments,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return PaymentLoaded(
      payments ?? this.payments,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [payments, currentPage, hasReachedMax];
}

class PaymentLoadingMore extends PaymentState {
  final List<PaymentModel> payments;
  final int currentPage;

  const PaymentLoadingMore(this.payments, this.currentPage);

  @override
  List<Object?> get props => [payments, currentPage];
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
