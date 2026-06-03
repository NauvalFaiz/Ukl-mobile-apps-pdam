import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotted/flutter_dotted.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/shared/widgets/full_screen_image_page.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_event.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_state.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/admin/presentation/widgets/transaction/admin_transaction_utils.dart';

class AdminPaymentsTab extends StatelessWidget {
  final ScrollController scrollController;

  const AdminPaymentsTab({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Antrean Konfirmasi Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF242E49),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state is PaymentLoading || state is PaymentOperationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<PaymentModel> allPayments = [];
              bool hasReachedMax = false;

              if (state is PaymentLoaded) {
                allPayments = state.payments;
                hasReachedMax = state.hasReachedMax;
              } else if (state is PaymentLoadingMore) {
                allPayments = state.payments;
              }

              // Filter to show only UNVERIFIED payments
              final unverifiedPayments = allPayments
                  .where((p) => !p.verified)
                  .toList();

              if (unverifiedPayments.isEmpty && hasReachedMax) {
                return const Center(
                  child: Text('Tidak ada antrean pembayaran'),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: unverifiedPayments.length,
                itemBuilder: (context, index) {
                  final p = unverifiedPayments[index];

                  final billState = context.read<BillBloc>().state;
                  BillModel? relatedBill;
                  if (billState is BillLoaded) {
                    try {
                      relatedBill = billState.bills.firstWhere(
                        (b) => b.id == p.billId,
                      );
                    } catch (e) {}
                  } else if (billState is BillLoadingMore) {
                    try {
                      relatedBill = billState.bills.firstWhere(
                        (b) => b.id == p.billId,
                      );
                    } catch (e) {}
                  }

                  return _PaymentCard(p: p, relatedBill: relatedBill);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatefulWidget {
  final PaymentModel p;
  final BillModel? relatedBill;

  const _PaymentCard({required this.p, required this.relatedBill});

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final relatedBill = widget.relatedBill;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer (ID: ${p.customerId != 0 ? p.customerId : (relatedBill != null ? relatedBill.customerId : 'Unknown')})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242E49),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tagihan: ${relatedBill != null ? getNamaBulan(relatedBill.month).toLowerCase() + ' ' + relatedBill.year.toString() : 'Bill #${p.billId}'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Total: ${relatedBill != null ? currencyFormat.format(relatedBill.price) : '-'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Text(
                  'Bukti Bayar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF242E49),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (p.file.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImagePage(
                            imageUrl:
                                '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(p.file)}',
                            tag: 'payment_image_admin_${p.id}',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tidak ada file bukti pembayaran',
                          ),
                        ),
                      );
                    }
                  },
                  child: FlutterDotted(
                    color: const Color(0xFF242E49),
                    gap: 4,
                    strokeWidth: 2,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 130,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.folder,
                            color: Color(0xFF0D6EFD),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.file.isNotEmpty
                                ? p.file.split('/').last
                                : 'Tidak ada file',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          context.read<PaymentBloc>().add(
                            VerifyPaymentEvent(p.id),
                          );
                        },
                        child: const Text(
                          'Terima',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA4D5E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Tolak',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
