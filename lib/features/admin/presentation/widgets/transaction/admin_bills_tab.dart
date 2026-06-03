import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_event.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/admin/presentation/widgets/transaction/admin_transaction_utils.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_state.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';

class AdminBillsTab extends StatelessWidget {
  final TextEditingController searchController;
  final ScrollController scrollController;
  final void Function(BillModel) onShowDetail;

  const AdminBillsTab({
    super.key,
    required this.searchController,
    required this.scrollController,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Cari ID / No. Meteran...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  context.read<BillBloc>().add(const SearchBillById(''));
                },
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              context.read<BillBloc>().add(SearchBillById(value));
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<BillBloc, BillState>(
            builder: (context, state) {
              if (state is BillLoading || state is BillOperationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<BillModel> bills = [];

              if (state is BillLoaded) {
                bills = state.bills;
              } else if (state is BillLoadingMore) {
                bills = state.bills;
              }

              if (bills.isEmpty) {
                return const Center(child: Text('Tidak ada tagihan'));
              }

              final paymentState = context.read<PaymentBloc>().state;
              List<PaymentModel> payments = [];
              if (paymentState is PaymentLoaded) {
                payments = paymentState.payments;
              } else if (paymentState is PaymentLoadingMore) {
                payments = paymentState.payments;
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final b = bills[index];

                  // Determine status
                  PaymentModel? relatedPayment;
                  try {
                    relatedPayment = payments.firstWhere(
                      (p) => p.billId == b.id,
                    );
                  } catch (e) {}

                  String status = 'BELUM LUNAS';
                  Color statusColor = const Color(0xFFFA4D5E);
                  Color iconBgColor = const Color(0xFFFFE5E8);
                  String iconPath = "assets/trans.svg";

                  if (b.paid) {
                    status = 'LUNAS';
                    statusColor = const Color(0xFF52B640);
                    iconBgColor = const Color(0xFFE8F6E3);
                    iconPath = "assets/icondone.svg";
                  } else if (relatedPayment != null &&
                      !relatedPayment.verified) {
                    status = 'MENUNGGU VERIFIKASI';
                    statusColor = const Color(0xFFFACC15);
                    iconBgColor = const Color(0xFFFEF9C3);
                    iconPath = "assets/service.svg";
                  }

                  return GestureDetector(
                    onTap: () => onShowDetail(b),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SvgPicture.asset(
                              iconPath,
                              colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill ${b.id.toString().padLeft(4, '0')} | ID: ${b.customerId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF242E49),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${getNamaBulan(b.month)} ${b.year} / ${currencyFormat.format(b.price)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
