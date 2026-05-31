import 'package:equatable/equatable.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';

abstract class BillState extends Equatable {
  const BillState();
  
  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  final List<BillModel> bills;
  final List<BillModel> allBills;
  const BillLoaded(this.bills, this.allBills);
  @override
  List<Object?> get props => [bills, allBills];
}

class BillOperationLoading extends BillState {}

class BillOperationSuccess extends BillState {
  final String message;
  const BillOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class BillError extends BillState {
  final String message;
  const BillError(this.message);
  @override
  List<Object?> get props => [message];
}
