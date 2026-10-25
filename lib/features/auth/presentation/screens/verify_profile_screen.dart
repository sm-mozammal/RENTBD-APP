import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rentbd_app/core/theme/app_colors.dart';
import 'package:rentbd_app/core/theme/app_typography.dart';
import 'package:rentbd_app/core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Screen for completing tenant or landlord profile details (occupation, workplace, family size, NID).
class VerifyProfileScreen extends StatefulWidget {
  const VerifyProfileScreen({super.key});

  @override
  State<VerifyProfileScreen> createState() => _VerifyProfileScreenState();
}

class _VerifyProfileScreenState extends State<VerifyProfileScreen> {
  final _nameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _nidController = TextEditingController();
  int _familySize = 3;
  bool _isNidSimulatedVerified = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final u = authState.user;
      _nameController.text = u.fullName;
      _occupationController.text = u.occupation;
      _workplaceController.text = u.workplace;
      _nidController.text = u.nidNumber;
      _familySize = u.familySize;
      _isNidSimulatedVerified = u.isNidVerified;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _occupationController.dispose();
    _workplaceController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  void _onSaveProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final updated = authState.user.copyWith(
        fullName: _nameController.text.trim(),
        occupation: _occupationController.text.trim(),
        workplace: _workplaceController.text.trim(),
        familySize: _familySize,
        nidNumber: _nidController.text.trim(),
        isNidVerified: _isNidSimulatedVerified || _nidController.text.trim().length >= 10,
      );

      context.read<AuthBloc>().add(UpdateProfileRequestedEvent(profile: updated));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile and credentials updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Credibility Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Credibility banner
              BariCard(
                backgroundColor: AppColors.primarySoft,
                borderColor: AppColors.primary.withAlpha(40),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verified tenants get 3x faster response from verified landlords with zero middleman interference.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              BariTextField(
                controller: _nameController,
                label: 'Full Legal Name',
                hintText: 'e.g. Tanvir Ahmed',
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              ),
              const SizedBox(height: 18),

              // Occupation
              BariTextField(
                controller: _occupationController,
                label: 'Occupation / Profession',
                hintText: 'e.g. Software Engineer, Banker, Doctor',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
              ),
              const SizedBox(height: 18),

              // Workplace / Organization
              BariTextField(
                controller: _workplaceController,
                label: 'Workplace / Company / University',
                hintText: 'e.g. Brain Station 23, Mohakhali',
                prefixIcon: const Icon(Icons.business_rounded, color: AppColors.primary),
              ),
              const SizedBox(height: 18),

              // Family Size Stepper
              Text(
                'Family Size (Members)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          '$_familySize Persons',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _familySize > 1 ? () => setState(() => _familySize--) : null,
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => _familySize++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // NID Verification
              BariTextField(
                controller: _nidController,
                label: 'National ID (NID) Number',
                hintText: '10 or 17 digit NID number',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNidSimulatedVerified
                        ? Icons.check_circle_rounded
                        : Icons.camera_alt_outlined,
                    color: _isNidSimulatedVerified ? AppColors.success : AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() => _isNidSimulatedVerified = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('NID Smart Scan simulated & verified!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your NID is encrypted and never shown publicly to other users.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted),
              ),

              const SizedBox(height: 32),
              BariButton(
                label: 'Save & Verify Profile',
                onPressed: _onSaveProfile,
                leadingIcon: const Icon(Icons.check_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
