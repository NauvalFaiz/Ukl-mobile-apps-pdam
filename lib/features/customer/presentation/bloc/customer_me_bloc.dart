import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/customer/data/datasources/customer_me_api_service.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';

class CustomerMeBloc extends Bloc<CustomerMeEvent, CustomerMeState> {
  final CustomerMeApiService apiService;

  CustomerMeBloc({required this.apiService}) : super(CustomerMeInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<FetchMyBills>(_onFetchMyBills);
    on<FetchMyPayments>(_onFetchMyPayments);
    on<UploadPaymentProof>(_onUploadPaymentProof);
  }

  Future<void> _onFetchDashboardData(FetchDashboardData event, Emitter<CustomerMeState> emit) async {
    emit(CustomerMeLoading());
    try {
      final profile = await apiService.getMyProfile();
      final bills = await apiService.getMyBills();
      emit(CustomerDashboardLoaded(profile, bills));
    } catch (e) {
      emit(CustomerMeError(e.toString()));
    }
  }

  Future<void> _onFetchMyBills(FetchMyBills event, Emitter<CustomerMeState> emit) async {
    emit(CustomerMeLoading());
    try {
      final bills = await apiService.getMyBills();
      emit(CustomerBillsLoaded(bills));
    } catch (e) {
      emit(CustomerMeError(e.toString()));
    }
  }

  Future<void> _onFetchMyPayments(FetchMyPayments event, Emitter<CustomerMeState> emit) async {
    emit(CustomerMeLoading());
    try {
      final payments = await apiService.getMyPayments();
      emit(CustomerPaymentsLoaded(payments));
    } catch (e) {
      emit(CustomerMeError(e.toString()));
    }
  }

  Future<void> _onUploadPaymentProof(UploadPaymentProof event, Emitter<CustomerMeState> emit) async {
    emit(CustomerMeOperationLoading());
    try {
      await apiService.uploadPayment(event.billId, event.filePath);
      emit(const CustomerMeOperationSuccess('Bukti bayar berhasil diunggah'));
    } catch (e) {
      emit(CustomerMeError(e.toString()));
    }
  }
}
