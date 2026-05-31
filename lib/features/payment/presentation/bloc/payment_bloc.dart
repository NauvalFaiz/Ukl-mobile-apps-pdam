import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/payment_api_service.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_event.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentApiService apiService;
  static const int _pageSize = 10;

  PaymentBloc({required this.apiService}) : super(PaymentInitial()) {
    on<FetchAllPayments>(_onFetchAllPayments);
    on<FetchMorePayments>(_onFetchMorePayments);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<DeletePaymentEvent>(_onDeletePayment);
  }

  Future<void> _onFetchAllPayments(FetchAllPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final payments = await apiService.getAllPayments(page: 1, limit: _pageSize);
      final hasReachedMax = payments.length < _pageSize;
      emit(PaymentLoaded(payments, currentPage: 1, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onFetchMorePayments(FetchMorePayments event, Emitter<PaymentState> emit) async {
    if (state is! PaymentLoaded) return;
    final currentState = state as PaymentLoaded;
    if (currentState.hasReachedMax) return;

    final nextPage = currentState.currentPage + 1;
    emit(PaymentLoadingMore(currentState.payments, currentState.currentPage));

    try {
      final morePayments = await apiService.getAllPayments(page: nextPage, limit: _pageSize);
      final allPayments = [...currentState.payments, ...morePayments];
      final hasReachedMax = morePayments.length < _pageSize;
      emit(PaymentLoaded(allPayments, currentPage: nextPage, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(PaymentLoaded(
        currentState.payments,
        currentPage: currentState.currentPage,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }

  Future<void> _onVerifyPayment(VerifyPaymentEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentOperationLoading());
    try {
      await apiService.verifyPayment(event.id, true);
      emit(const PaymentOperationSuccess('Pembayaran berhasil diverifikasi'));
      add(FetchAllPayments());
    } catch (e) {
      emit(PaymentError(e.toString()));
      add(FetchAllPayments());
    }
  }

  Future<void> _onDeletePayment(DeletePaymentEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentOperationLoading());
    try {
      await apiService.deletePayment(event.id);
      emit(const PaymentOperationSuccess('Pembayaran berhasil dihapus'));
      add(FetchAllPayments());
    } catch (e) {
      emit(PaymentError(e.toString()));
      add(FetchAllPayments());
    }
  }
}