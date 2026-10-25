import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';

class _LedgerMonth {
  _LedgerMonth({
    required this.monthYear,
    required this.rent,
    required this.serviceCharge,
    required this.electricityBill,
    required this.gasBill,
    required this.isPaid,
    this.paidDate,
    required this.receiptNumber,
  });

  final String monthYear;
  final double rent;
  final double serviceCharge;
  final double electricityBill;
  final double gasBill;
  bool isPaid;
  String? paidDate;
  final String receiptNumber;

  double get total => rent + serviceCharge + electricityBill + gasBill;
}

/// Digital Rent & Utility Ledger with digital receipts and payment reminders.
class DigitalLedgerScreen extends StatefulWidget {
  const DigitalLedgerScreen({super.key});

  @override
  State<DigitalLedgerScreen> createState() => _DigitalLedgerScreenState();
}

class _DigitalLedgerScreenState extends State<DigitalLedgerScreen> {
  final List<_LedgerMonth> _records = [
    _LedgerMonth(
      monthYear: 'October 2026 (Current)',
      rent: 16500,
      serviceCharge: 2500,
      electricityBill: 1200,
      gasBill: 1080,
      isPaid: false,
      receiptNumber: 'REC-2026-10-88',
    ),
    _LedgerMonth(
      monthYear: 'September 2026',
      rent: 16500,
      serviceCharge: 2500,
      electricityBill: 1450,
      gasBill: 1080,
      isPaid: true,
      paidDate: '03 Sep 2026',
      receiptNumber: 'REC-2026-09-41',
    ),
    _LedgerMonth(
      monthYear: 'August 2026',
      rent: 16500,
      serviceCharge: 2500,
      electricityBill: 1380,
      gasBill: 1080,
      isPaid: true,
      paidDate: '04 Aug 2026',
      receiptNumber: 'REC-2026-08-19',
    ),
  ];

  void _showReceiptDialog(_LedgerMonth rec) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.receipt_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Digital Rent Receipt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt #: ${rec.receiptNumber}', style: AppTypography.titleSmall),
            Text('Month: ${rec.monthYear}', style: AppTypography.bodySmall),
            const Divider(height: 16),
            _buildDialogRow('Base Rent', '৳ ${rec.rent.toInt()}'),
            _buildDialogRow('Service Charge', '৳ ${rec.serviceCharge.toInt()}'),
            _buildDialogRow('Electricity Sub-meter', '৳ ${rec.electricityBill.toInt()}'),
            _buildDialogRow('Titas Gas Bill', '৳ ${rec.gasBill.toInt()}'),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Paid', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('৳ ${rec.total.toInt()}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  SizedBox(width: 6),
                  Text('Signed digitally by landlord (bKash/Bank verified)'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          BariButton(
            label: 'Download PDF',
            isFullWidth: false,
            height: 38,
            leadingIcon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Digital receipt PDF downloaded to phone!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(val, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Rent & Utility Ledger'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Current month highlight card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'October 2026 • Payment Due',
                    style: AppTypography.titleSmall.copyWith(color: Colors.white.withAlpha(220)),
                  ),
                  const SizedBox(height: 6),
                  BariPriceTag(
                    amount: _records.first.total,
                    color: Colors.white,
                    showPeriod: false,
                    size: BariPriceSize.hero,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rent: ৳ 16,500 + Service: ৳ 2,500 + Electricity: ৳ 1,200 + Gas: ৳ 1,080',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withAlpha(200)),
                  ),
                  const SizedBox(height: 16),
                  BariButton(
                    label: _records.first.isPaid ? 'Paid via bKash ✓' : 'Mark as Paid / Send Reminder',
                    variant: BariButtonVariant.secondary,
                    height: 42,
                    onPressed: () {
                      setState(() {
                        _records.first.isPaid = !_records.first.isPaid;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _records.first.isPaid
                                ? 'Payment recorded! Digital receipt issued.'
                                : 'Automated payment reminder SMS sent to tenant!',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Monthly Ledger History',
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            ..._records.map((rec) {
              return BariCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rec.monthYear,
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: rec.isPaid ? AppColors.successSoft : AppColors.errorSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            rec.isPaid ? 'PAID' : 'DUE',
                            style: AppTypography.labelSmall.copyWith(
                              color: rec.isPaid ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ৳ ${rec.total.toInt()}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (rec.isPaid)
                          TextButton.icon(
                            icon: const Icon(Icons.receipt_rounded, size: 16),
                            label: const Text('View Receipt'),
                            onPressed: () => _showReceiptDialog(rec),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
