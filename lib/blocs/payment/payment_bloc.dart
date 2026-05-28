import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/dio_client.dart';
import '../../models/payment_model.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final DioClient dioClient;

  PaymentBloc({required this.dioClient}) : super(PaymentInitial()) {
    on<FetchPayments>(_onFetchPayments);
    on<FetchCustomerPayments>(_onFetchCustomerPayments);
  }

  Future<void> _onFetchPayments(FetchPayments event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final response = await dioClient.dio.get('/payments');
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
      final response = await dioClient.dio.get('/payments/me');
      final data = response.data['data'] as List;
      final payments = data.map((json) => PaymentModel.fromJson(json)).toList();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }
}
