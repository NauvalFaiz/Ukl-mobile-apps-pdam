import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllBills extends BillEvent {}

class SearchBillById extends BillEvent {
  final String query;
  const SearchBillById(this.query);
  @override
  List<Object?> get props => [query];
}

class CreateBillEvent extends BillEvent {
  final Map<String, dynamic> data;
  const CreateBillEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateBillEvent extends BillEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateBillEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteBillEvent extends BillEvent {
  final int id;
  const DeleteBillEvent(this.id);
  @override
  List<Object?> get props => [id];
}
