import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/customer_api_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/customer/customer_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/customer/customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerApiService apiService;

  CustomerBloc({required this.apiService}) : super(CustomerInitial()) {
    on<FetchAllCustomers>(_onFetchAllCustomers);
    on<SearchCustomerByName>(_onSearchCustomerByName);
    on<FetchCustomerById>(_onFetchCustomerById);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onFetchAllCustomers(FetchAllCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await apiService.getAllCustomers();
      emit(CustomerLoaded(customers, customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  void _onSearchCustomerByName(SearchCustomerByName event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      final query = event.query.toLowerCase();
      
      final filteredCustomers = currentState.allCustomers.where((customer) {
        return customer.name.toLowerCase().contains(query) || 
               customer.customerNumber.toLowerCase().contains(query);
      }).toList();

      emit(CustomerLoaded(filteredCustomers, currentState.allCustomers));
    }
  }

  Future<void> _onFetchCustomerById(FetchCustomerById event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customer = await apiService.getCustomerById(event.id);
      emit(CustomerDetailLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(FetchAllCustomers()); // Back to list on error
    }
  }

  Future<void> _onCreateCustomer(CreateCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerOperationLoading());
    try {
      await apiService.createCustomer(event.data);
      emit(const CustomerOperationSuccess('Pelanggan berhasil ditambahkan'));
      add(FetchAllCustomers()); // Refresh list
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(FetchAllCustomers());
    }
  }

  Future<void> _onUpdateCustomer(UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerOperationLoading());
    try {
      await apiService.updateCustomer(event.id, event.data);
      emit(const CustomerOperationSuccess('Data pelanggan berhasil diperbarui'));
      add(FetchAllCustomers()); // Refresh list
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(FetchAllCustomers());
    }
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerOperationLoading());
    try {
      await apiService.deleteCustomer(event.id);
      emit(const CustomerOperationSuccess('Pelanggan berhasil dihapus'));
      add(FetchAllCustomers()); // Refresh list
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(FetchAllCustomers());
    }
  }
}
