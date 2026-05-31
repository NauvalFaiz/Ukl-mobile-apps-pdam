import 'package:equatable/equatable.dart';

abstract class CustomerMeEvent extends Equatable {
  const CustomerMeEvent();
  @override
  List<Object?> get props => [];
}

class FetchDashboardData extends CustomerMeEvent {}
class FetchMyBills extends CustomerMeEvent {}
class FetchMyPayments extends CustomerMeEvent {}
class UploadPaymentProof extends CustomerMeEvent {
  final int billId;
  final String filePath;
  const UploadPaymentProof(this.billId, this.filePath);
  @override
  List<Object?> get props => [billId, filePath];
}
