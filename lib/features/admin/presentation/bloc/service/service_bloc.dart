import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/service_api_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceApiService apiService;

  ServiceBloc({required this.apiService}) : super(ServiceInitial()) {
    on<FetchAllServices>(_onFetchAllServices);
    on<SearchServiceByName>(_onSearchServiceByName);
    on<CreateServiceEvent>(_onCreateService);
    on<UpdateServiceEvent>(_onUpdateService);
    on<DeleteServiceEvent>(_onDeleteService);
  }

  Future<void> _onFetchAllServices(FetchAllServices event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    try {
      final services = await apiService.getAllServices();
      emit(ServiceLoaded(services, services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }

  void _onSearchServiceByName(SearchServiceByName event, Emitter<ServiceState> emit) {
    if (state is ServiceLoaded) {
      final currentState = state as ServiceLoaded;
      final query = event.query.toLowerCase();
      
      final filteredServices = currentState.allServices.where((service) {
        return service.name.toLowerCase().contains(query);
      }).toList();

      emit(ServiceLoaded(filteredServices, currentState.allServices));
    }
  }

  Future<void> _onCreateService(CreateServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceOperationLoading());
    try {
      await apiService.createService(event.data);
      emit(const ServiceOperationSuccess('Layanan berhasil dibuat'));
      add(FetchAllServices()); // Refresh list
    } catch (e) {
      emit(ServiceError(e.toString()));
      add(FetchAllServices()); // Revert state back to loaded list
    }
  }

  Future<void> _onUpdateService(UpdateServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceOperationLoading());
    try {
      await apiService.updateService(event.id, event.data);
      emit(const ServiceOperationSuccess('Layanan berhasil diperbarui'));
      add(FetchAllServices()); // Refresh list
    } catch (e) {
      emit(ServiceError(e.toString()));
      add(FetchAllServices());
    }
  }

  Future<void> _onDeleteService(DeleteServiceEvent event, Emitter<ServiceState> emit) async {
    emit(ServiceOperationLoading());
    try {
      await apiService.deleteService(event.id);
      emit(const ServiceOperationSuccess('Layanan berhasil dihapus'));
      add(FetchAllServices()); // Refresh list
    } catch (e) {
      emit(ServiceError(e.toString()));
      add(FetchAllServices());
    }
  }
}
