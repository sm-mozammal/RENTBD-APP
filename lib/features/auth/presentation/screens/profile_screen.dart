import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/router/route_names.dart';
import 'package:rentbd_app/core/theme/app_colors.dart';
import 'package:rentbd_app/core/theme/app_typography.dart';
import 'package:rentbd_app/core/widgets/widgets.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Full Profile, Credential Update, Password Management & KYC Validation Dashboard.
/// Dynamically tailors UI between Tenant (ভাড়াটিয়া) and Landlord (বাড়িওয়ালা) roles.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
      }
    });
  }

  void _showUpdateProfileSheet(BuildContext context, UserProfile user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final occCtrl = TextEditingController(text: user.occupation);
    final workCtrl = TextEditingController(text: user.workplace);
    final addressCtrl = TextEditingController(text: user.presentAddress);
    final emergencyCtrl = TextEditingController(text: user.emergencyContact);
    int familySize = user.familySize;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Update Profile Information',
                      style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Keep your details up to date for official rent agreements.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    BariTextField(
                      controller: nameCtrl,
                      label: 'Full Legal Name',
                      hintText: 'e.g. Tanvir Hasan',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),

                    // Email Address
                    BariTextField(
                      controller: emailCtrl,
                      label: 'Email Address',
                      hintText: 'e.g. tanvir@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),

                    // Occupation
                    BariTextField(
                      controller: occCtrl,
                      label: 'Occupation / Profession',
                      hintText: 'e.g. Software Engineer, Banker',
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),

                    // Workplace
                    BariTextField(
                      controller: workCtrl,
                      label: 'Workplace / Employer',
                      hintText: 'e.g. Brain Station 23, Mohakhali',
                      prefixIcon: const Icon(Icons.business_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),

                    // Present Address
                    BariTextField(
                      controller: addressCtrl,
                      label: 'Present Address in Dhaka',
                      hintText: 'e.g. House 42, Road 11, Banani, Dhaka',
                      prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),

                    // Emergency Contact
                    BariTextField(
                      controller: emergencyCtrl,
                      label: 'Emergency Contact Person & Phone',
                      hintText: 'e.g. Rafiqul Islam (Father) - 01711223344',
                      prefixIcon: const Icon(Icons.contact_phone_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),

                    // Family Size
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Family Size: $familySize Persons',
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: familySize > 1
                                  ? () => setModalState(() => familySize--)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => setModalState(() => familySize++),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    BariButton(
                      label: 'Save Changes',
                      onPressed: () {
                        final updated = user.copyWith(
                          fullName: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          occupation: occCtrl.text.trim(),
                          workplace: workCtrl.text.trim(),
                          presentAddress: addressCtrl.text.trim(),
                          emergencyContact: emergencyCtrl.text.trim(),
                          familySize: familySize,
                        );
                        context.read<AuthBloc>().add(UpdateProfileRequestedEvent(profile: updated));
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      leadingIcon: const Icon(Icons.check_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final curPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCur = true;
    bool obscureNew = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Change Account Password',
                      style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Choose a strong password to protect your account.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Current Password
                    BariTextField(
                      controller: curPassCtrl,
                      label: 'Current Password',
                      hintText: 'Enter your current password',
                      obscureText: obscureCur,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCur ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.lightTextMuted,
                        ),
                        onPressed: () => setModalState(() => obscureCur = !obscureCur),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // New Password
                    BariTextField(
                      controller: newPassCtrl,
                      label: 'New Password',
                      hintText: 'Minimum 6 characters',
                      obscureText: obscureNew,
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.lightTextMuted,
                        ),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm New Password
                    BariTextField(
                      controller: confirmPassCtrl,
                      label: 'Confirm New Password',
                      hintText: 'Re-enter new password',
                      obscureText: obscureNew,
                      prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),

                    BariButton(
                      label: 'Update Password',
                      onPressed: () {
                        if (newPassCtrl.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password must be at least 6 characters'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        if (newPassCtrl.text != confirmPassCtrl.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        context.read<AuthBloc>().add(
                              ChangePasswordRequestedEvent(
                                currentPassword: curPassCtrl.text,
                                newPassword: newPassCtrl.text,
                              ),
                            );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      leadingIcon: const Icon(Icons.lock_reset_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequestedEvent());
              context.goNamed(RouteNames.login);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return BariEmptyState(
              icon: Icons.account_circle_outlined,
              title: 'Sign in to access profile',
              message: 'Verify your occupation and NID to contact landlords directly.',
              actionLabel: 'Sign In via OTP',
              onAction: () => context.pushNamed(RouteNames.login),
            );
          }

          final user = state.user;
          final isLandlord = user.isLandlord;
          final isKycDone = user.isKycCompleted;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AuthBloc>().add(const CheckAuthStatusEvent());
              },
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                // Profile Card
                BariCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          BariAvatar(
                            name: user.fullName,
                            radius: 32,
                            isVerified: isKycDone,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.fullName,
                                        style: AppTypography.headlineMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isKycDone) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.phoneNumber,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (user.email.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.lightTextSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  user.occupation.isNotEmpty
                                      ? '${user.occupation} • ${user.workplace}'
                                      : 'Profession not set',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.lightTextMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Profile Action Buttons (Edit Profile & Change Password)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Update Profile'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () => _showUpdateProfileSheet(context, user),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.lock_outline_rounded, size: 16),
                              label: const Text('Password'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () => _showChangePasswordSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // LANDLORD KYC VALIDATION CARD (বাড়িওয়ালা NID ভেরিফিকেশন - রেন্ট পোস্টের জন্য আবশ্যক)
                if (isLandlord) ...[
                  BariCard(
                    backgroundColor: isKycDone ? AppColors.primarySoft : AppColors.warningSoft,
                    borderColor: isKycDone
                        ? AppColors.primary.withAlpha(60)
                        : AppColors.warning.withAlpha(100),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isKycDone ? Icons.verified_user_rounded : Icons.shield_rounded,
                              color: isKycDone ? AppColors.primary : AppColors.warning,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isKycDone
                                    ? 'DMP & NID Verified Landlord (ভেরিফাইড)'
                                    : 'Landlord KYC Required (বাড়িওয়ালা ভেরিফিকেশন)',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isKycDone ? AppColors.primaryDark : AppColors.warning,
                                ),
                              ),
                            ),
                            BariBadge(
                              type: BariBadgeType.custom,
                              customLabel: isKycDone ? 'Verified' : 'Required to Post',
                              customColor: isKycDone ? AppColors.primary : AppColors.warning,
                              customBgColor: isKycDone ? AppColors.primarySoft : AppColors.warningSoft,
                              isCompact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isKycDone
                              ? 'আপনার জাতীয় পরিচয়পত্র (NID) অনুমোদিত। আপনি ভল্ট থেকে সরাসরি নতুন বাসা বা ফ্ল্যাট রেন্ট পোস্ট করতে পারবেন।'
                              : 'ফ্ল্যাট বা বাসা রেন্ট পোস্ট করতে হলে বাড়িওয়ালা হিসেবে আপনার জাতীয় পরিচয়পত্র (NID) ভেরিফিকেশন সম্পন্ন থাকা আবশ্যক।',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.lightTextSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: BariButton(
                            label: isKycDone ? 'View Landlord KYC Details' : 'Verify Landlord KYC (এখনই NID ভেরিফাই করুন)',
                            variant: isKycDone ? BariButtonVariant.secondary : BariButtonVariant.primary,
                            leadingIcon: Icon(
                              isKycDone ? Icons.verified_outlined : Icons.shield_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () => context.pushNamed(RouteNames.kycVerification),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 1-Tap Role Switcher Card (ভাড়াটিয়া <-> বাড়িওয়ালা)
                BariCard(
                  backgroundColor: isLandlord ? AppColors.primarySoft : AppColors.familySoft,
                  borderColor: isLandlord
                      ? AppColors.primary.withAlpha(60)
                      : AppColors.family.withAlpha(60),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        isLandlord ? Icons.apartment_rounded : Icons.person_pin_circle_rounded,
                        color: isLandlord ? AppColors.primaryDark : AppColors.family,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLandlord ? 'Mode: Landlord (বাড়িওয়ালা)' : 'Mode: Tenant (ভাড়াটিয়া)',
                              style: AppTypography.titleMedium.copyWith(
                                color: isLandlord ? AppColors.primaryDark : AppColors.family,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isLandlord
                                  ? 'Manage property vault, quick post & screening'
                                  : 'Search flats, schedule visits & track rent',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isLandlord,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          final newRole = val ? UserRole.landlord : UserRole.tenant;
                          context.read<AuthBloc>().add(SwitchRoleRequestedEvent(newRole: newRole));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Role-Based Tools & Feature Section
                Text(
                  isLandlord ? 'Landlord Tools (বাড়িওয়ালার ফিচার)' : 'Tenant Tools (ভাড়াটিয়ার ফিচার)',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                if (isLandlord) ...[
                  // Landlord Flow Items
                  _buildMenuItem(
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    title: '1-Tap Re-Listing (Property Vault)',
                    subtitle: 'Save rented flats & re-publish vacancy in 1 tap',
                    onTap: () => context.pushNamed(RouteNames.propertyVault),
                  ),
                  _buildMenuItem(
                    icon: Icons.add_circle_outline_rounded,
                    color: AppColors.primaryDark,
                    title: 'Post Property in 60 Seconds',
                    subtitle: 'Create a new flat or sublet listing with AI rent suggestions',
                    onTap: () {
                      if (!user.isKycCompleted) {
                        _showLandlordKycRequiredDialog(context);
                      } else {
                        context.pushNamed(RouteNames.quickPost);
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.inbox_rounded,
                    color: AppColors.secondary,
                    title: 'Tenant Screening Inbox',
                    subtitle: 'Review tenant verified profiles, NID status & past ratings',
                    onTap: () => context.pushNamed(RouteNames.tenantScreening),
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.info,
                    title: 'Rent Collection & Digital Ledger',
                    subtitle: 'Track tenant payments, utility bills & generate receipts',
                    onTap: () => context.pushNamed(RouteNames.digitalLedger),
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    color: AppColors.bachelor,
                    title: 'AI Rent Agreement Generator',
                    subtitle: 'Generate printable Bengali/English 300-taka stamp agreement',
                    onTap: () => context.pushNamed(
                      RouteNames.rentAgreement,
                      pathParameters: {'propertyId': 'prop-mirpur-01'},
                    ),
                  ),
                ] else ...[
                  // Tenant Flow Items
                  _buildMenuItem(
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    title: 'My Scheduled Property Visits',
                    subtitle: 'Track confirmed visit timings & landlord GPS locations',
                    onTap: () => context.pushNamed(RouteNames.visits),
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    color: AppColors.error,
                    title: 'Saved & Shortlisted Flats',
                    subtitle: 'View saved properties and price change alerts',
                    onTap: () => context.pushNamed(RouteNames.saved),
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.info,
                    title: 'Digital Rent & Utility Ledger',
                    subtitle: 'Track rent payments, bKash receipts & security deposits',
                    onTap: () => context.pushNamed(RouteNames.digitalLedger),
                  ),
                  _buildMenuItem(
                    icon: Icons.calculate_outlined,
                    color: AppColors.sublet,
                    title: 'Move-in Cost Estimator',
                    subtitle: 'Calculate security advance, utility costs & moving truck fee',
                    onTap: () => context.pushNamed(
                      RouteNames.moveInCalculator,
                      pathParameters: {'id': 'prop-mirpur-01'},
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.directions_car_rounded,
                    color: AppColors.family,
                    title: 'Office / University Commute Calculator',
                    subtitle: 'Estimate peak traffic time to Gulshan, Motijheel, Kawran Bazar',
                    onTap: () => context.pushNamed(RouteNames.commuteCalculator),
                  ),
                  _buildMenuItem(
                    icon: Icons.compare_arrows_rounded,
                    color: AppColors.bachelor,
                    title: 'Side-by-Side Property Comparison',
                    subtitle: 'Evaluate 2-3 shortlisted flats side-by-side',
                    onTap: () => context.pushNamed(RouteNames.compare),
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    color: AppColors.secondary,
                    title: 'AI Rent Agreement Generator',
                    subtitle: 'Pre-fill your details into official rental agreement',
                    onTap: () => context.pushNamed(
                      RouteNames.rentAgreement,
                      pathParameters: {'propertyId': 'prop-mirpur-01'},
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                // System Environment Status
                BariCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: AppColors.lightBackground,
                  child: Row(
                    children: [
                      const Icon(Icons.developer_mode_rounded, size: 20, color: AppColors.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DataSource: ${AppEnvironment.useMockData ? "Realistic Mock Engine" : "Live Django DRF"}',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Dhaka Metropolitan • Currency: BDT (৳)',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BariBadge(
                        type: BariBadgeType.custom,
                        customLabel: AppEnvironment.useMockData ? 'Mock Active' : 'API Active',
                        customColor: AppColors.secondary,
                        customBgColor: AppColors.secondarySoft,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: BariCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showLandlordKycRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 10),
            Flexible(child: Text('NID Verification Required / KYC আবশ্যক')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'বাড়িওয়ালা হিসেবে ফ্ল্যাট বা বাসা ভাড়ার লিস্টিং তৈরি ও প্রকাশ করতে আপনার জাতীয় পরিচয়পত্র (NID) ভেরিফিকেশন (KYC) সম্পন্ন করা আবশ্যক।',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'KYC সম্পন্ন না করা পর্যন্ত আপনি নতুন লিস্টিং তৈরি বা প্রকাশ করতে পারবেন না।',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('পরে করব'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.verified_user_rounded, size: 18),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pushNamed(RouteNames.kycVerification);
            },
            label: const Text('Verify NID Now (কেওয়াইসি করুন)'),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('প্রোপার্টি তৈরি করতে আগে NID ভেরিফিকেশন (KYC) সম্পন্ন করুন।'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
