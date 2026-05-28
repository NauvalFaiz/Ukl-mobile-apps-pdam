import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final ApiClient apiClient;

  BillBloc({required this.apiClient}) : super(BillInitial()) {
    on<FetchAllBills>(_onFetchAllBills);
    on<FetchCustomerBills>(_onFetchCustomerBills);
  }

  Future<void> _onFetchAllBills(FetchAllBills event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final response = await apiClient.dio.get('/bills');
      final data = response.data['data'] as List; // asumsikan array ada di 'data'
      final bills = data.map((json) => BillModel.fromJson(json)).toList();
      emit(BillLoaded(bills));
    } catch (e) {
      emit(BillFailure(e.toString()));
    }
  }

  Future<void> _onFetchCustomerBills(FetchCustomerBills event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final response = await apiClient.dio.get('/bills/me');
      
      final data = response.data['data'] as List;
      final bills = data.map((json) => BillModel.fromJson(json)).toList();
      emit(BillLoaded(bills));
    } catch (e) {
      emit(BillFailure(e.toString()));
    }
  }
}
