import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ApiClient apiClient;

  PaymentBloc({required this.apiClient}) : super(PaymentInitial()) {
    on<FetchPayments>(_onFetchPayments);
    on<FetchCustomerPayments>(_onFetchCustomerPayments);
  }

  Future<void> _onFetchPayments(FetchPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final response = await apiClient.dio.get('/payments');
      final data = response.data['data'] as List;
      final payments = data.map((json) => PaymentModel.fromJson(json)).toList();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onFetchCustomerPayments(FetchCustomerPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final response = await apiClient.dio.get('/payments/me');
      final data = response.data['data'] as List;
      final payments = data.map((json) => PaymentModel.fromJson(json)).toList();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }
}
