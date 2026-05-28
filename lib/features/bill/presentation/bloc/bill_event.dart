import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

class FetchAllBills extends BillEvent {}
class FetchCustomerBills extends BillEvent {}
