import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';

abstract class BillState extends Equatable {
  const BillState();
  
  @override
  List<Object> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  final List<BillModel> bills;
  const BillLoaded(this.bills);

  @override
  List<Object> get props => [bills];
}

class BillFailure extends BillState {
  final String error;
  const BillFailure(this.error);

  @override
  List<Object> get props => [error];
}
