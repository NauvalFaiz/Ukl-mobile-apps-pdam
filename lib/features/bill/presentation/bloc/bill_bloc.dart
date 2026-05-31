import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/bill_api_service.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_event.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final BillApiService apiService;
  static const int _pageSize = 10;

  BillBloc({required this.apiService}) : super(BillInitial()) {
    on<FetchAllBills>(_onFetchAllBills);
    on<FetchMoreBills>(_onFetchMoreBills);
    on<SearchBillById>(_onSearchBillById);
    on<CreateBillEvent>(_onCreateBill);
    on<UpdateBillEvent>(_onUpdateBill);
    on<DeleteBillEvent>(_onDeleteBill);
  }

  Future<void> _onFetchAllBills(FetchAllBills event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final bills = await apiService.getAllBills(page: 1, limit: _pageSize);
      final hasReachedMax = bills.length < _pageSize;
      emit(BillLoaded(bills, bills, currentPage: 1, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> _onFetchMoreBills(FetchMoreBills event, Emitter<BillState> emit) async {
    if (state is! BillLoaded) return;
    final currentState = state as BillLoaded;
    if (currentState.hasReachedMax) return;

    final nextPage = currentState.currentPage + 1;
    emit(BillLoadingMore(currentState.bills, currentState.allBills, currentState.currentPage));

    try {
      final moreBills = await apiService.getAllBills(page: nextPage, limit: _pageSize);
      final allBills = [...currentState.allBills, ...moreBills];
      final hasReachedMax = moreBills.length < _pageSize;
      emit(BillLoaded(allBills, allBills, currentPage: nextPage, hasReachedMax: hasReachedMax));
    } catch (e) {
      emit(BillLoaded(
        currentState.bills,
        currentState.allBills,
        currentPage: currentState.currentPage,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }

  void _onSearchBillById(SearchBillById event, Emitter<BillState> emit) {
    if (state is BillLoaded) {
      final currentState = state as BillLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.allBills.where((bill) {
        return bill.id.toString().contains(query) ||
            bill.measurementNumber.toLowerCase().contains(query);
      }).toList();
      emit(currentState.copyWith(bills: filtered));
    } else if (state is BillLoadingMore) {
      final currentState = state as BillLoadingMore;
      final query = event.query.toLowerCase();
      final filtered = currentState.allBills.where((bill) {
        return bill.id.toString().contains(query) ||
            bill.measurementNumber.toLowerCase().contains(query);
      }).toList();
      emit(BillLoaded(filtered, currentState.allBills, currentPage: currentState.currentPage));
    }
  }

  Future<void> _onCreateBill(CreateBillEvent event, Emitter<BillState> emit) async {
    emit(BillOperationLoading());
    try {
      await apiService.createBill(event.data);
      emit(const BillOperationSuccess('Tagihan berhasil dibuat'));
      add(FetchAllBills());
    } catch (e) {
      emit(BillError(e.toString()));
      add(FetchAllBills());
    }
  }

  Future<void> _onUpdateBill(UpdateBillEvent event, Emitter<BillState> emit) async {
    emit(BillOperationLoading());
    try {
      await apiService.updateBill(event.id, event.data);
      emit(const BillOperationSuccess('Tagihan berhasil diperbarui'));
      add(FetchAllBills());
    } catch (e) {
      emit(BillError(e.toString()));
      add(FetchAllBills());
    }
  }

  Future<void> _onDeleteBill(DeleteBillEvent event, Emitter<BillState> emit) async {
    emit(BillOperationLoading());
    try {
      await apiService.deleteBill(event.id);
      emit(const BillOperationSuccess('Tagihan berhasil dihapus'));
      add(FetchAllBills());
    } catch (e) {
      emit(BillError(e.toString()));
      add(FetchAllBills());
    }
  }
}
