import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/payment_api_service.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_event.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentApiService apiService;

  PaymentBloc({required this.apiService}) : super(PaymentInitial()) {
    on<FetchAllPayments>(_onFetchAllPayments);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<DeletePaymentEvent>(_onDeletePayment);
  }

  Future<void> _onFetchAllPayments(FetchAllPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final payments = await apiService.getAllPayments();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
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