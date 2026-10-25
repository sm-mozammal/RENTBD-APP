import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// 1-Click AI Rent Agreement Generator & Contract Preview.
class AiRentAgreementScreen extends StatefulWidget {
  const AiRentAgreementScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<AiRentAgreementScreen> createState() => _AiRentAgreementScreenState();
}

class _AiRentAgreementScreenState extends State<AiRentAgreementScreen> {
  final _tenantNameController = TextEditingController(text: 'Tanvir Ahmed');
  final _tenantNidController = TextEditingController(text: '19942691234567890');
  final _landlordNameController = TextEditingController(text: 'Engr. Farhan Kabir');
  final _landlordNidController = TextEditingController(text: '19822699876543210');
  final _rentAmountController = TextEditingController(text: '16500');
  final _depositController = TextEditingController(text: '33000');
  final _noticePeriodController = TextEditingController(text: '2 Months');
  final _startDateController = TextEditingController(text: '1st November 2026');

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.isTenant) {
      if (authState.user.fullName.isNotEmpty) {
        _tenantNameController.text = authState.user.fullName;
      }
      if (authState.user.nidNumber.isNotEmpty) {
        _tenantNidController.text = authState.user.nidNumber;
      }
    }
  }

  void _onGenerateContract() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Legal tenancy contract PDF generated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Rent Agreement Generator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Legal assistant badge
            BariCard(
              backgroundColor: AppColors.primarySoft,
              borderColor: AppColors.primary.withAlpha(50),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ready-to-print standard Bangladeshi tenancy contract compliant with Dhaka Metropolitan Police (DMP) tenant verification form.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Populated NID & Party Fields
            Text(
              'Landlord & Tenant Verified Parties',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BariTextField(
                    controller: _landlordNameController,
                    label: 'Landlord Name',
                    prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BariTextField(
                    controller: _landlordNidController,
                    label: 'Landlord NID',
                    prefixIcon: const Icon(Icons.badge, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BariTextField(
                    controller: _tenantNameController,
                    label: 'Tenant Name',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BariTextField(
                    controller: _tenantNidController,
                    label: 'Tenant NID',
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial & Tenancy terms
            Text(
              'Agreed Tenancy Terms',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BariTextField(
                    controller: _rentAmountController,
                    label: 'Monthly Rent (৳)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BariTextField(
                    controller: _depositController,
                    label: 'Security Deposit (৳)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BariTextField(
                    controller: _noticePeriodController,
                    label: 'Notice Period',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BariTextField(
                    controller: _startDateController,
                    label: 'Agreement Start Date',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Document Preview Paper Card
            BariCard(
              backgroundColor: Colors.white,
              borderColor: AppColors.lightBorder,
              padding: const EdgeInsets.all(20),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'ভাড়া চুক্তিপত্র / RESIDENTIAL TENANCY CONTRACT',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'This Tenancy Agreement is entered on ${_startDateController.text} between ${_landlordNameController.text} (Landlord, NID: ${_landlordNidController.text}) and ${_tenantNameController.text} (Tenant, NID: ${_tenantNidController.text}).\n\n'
                    '1. The tenant agrees to pay a monthly rent of BDT ${_rentAmountController.text} by the 7th of every English calendar month.\n'
                    '2. The tenant deposits an advance security money of BDT ${_depositController.text}, refundable upon completion of lease.\n'
                    '3. Either party may terminate this agreement with a minimum notice of ${_noticePeriodController.text}.\n'
                    '4. Both parties agree to abide by the safety regulations of Dhaka Metropolitan Police (DMP).',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSignatureLine('Landlord Signature'),
                      _buildSignatureLine('Tenant Signature'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            BariButton(
              label: 'Generate & Download Ready-to-Print Contract (PDF)',
              leadingIcon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              onPressed: _onGenerateContract,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureLine(String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 1,
          color: AppColors.lightTextMuted,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
        ),
      ],
    );
  }
}
