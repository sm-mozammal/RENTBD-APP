import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/error_formatter.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../visit/domain/entities/tenant_inquiry.dart';
import '../../../visit/domain/repositories/visit_repository.dart';

/// Tenant Screening Inbox for verified landlord inquiry reviews.
/// Fetches prospective tenant applications live from the backend API.
class TenantScreeningScreen extends StatefulWidget {
  const TenantScreeningScreen({super.key});

  @override
  State<TenantScreeningScreen> createState() => _TenantScreeningScreenState();
}

class _TenantScreeningScreenState extends State<TenantScreeningScreen> {
  List<TenantInquiry> _inquiries = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, String> _localStatusOverrides = {};

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
      }
    });
  }

  Future<void> _fetchInquiries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await sl<VisitRepository>().getLandlordScreeningInbox();
      if (!mounted) return;
      setState(() {
        _inquiries = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = RentBdErrorFormatter.format(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    await _fetchInquiries();
  }

  void _onAccept(TenantInquiry inquiry) {
    setState(() {
      _localStatusOverrides[inquiry.id] = 'accepted';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application accepted! Direct chat unlocked with tenant.'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pushNamed(
      RouteNames.chatRoom,
      pathParameters: {'id': inquiry.id},
    );
  }

  void _onDecline(TenantInquiry inquiry) {
    setState(() {
      _localStatusOverrides[inquiry.id] = 'declined';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application declined.'),
        backgroundColor: AppColors.lightTextSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isKycCompleted = authState is Authenticated ? authState.user.isKycCompleted : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Screening Inbox'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Landlord KYC Required Warning Card
              if (!isKycCompleted)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NID ভেরিফিকেশন (KYC) পেন্ডিং',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ভাড়াটিয়া স্ক্রিনিং ও লিস্টিং ম্যানেজ করতে NID ভেরিফিকেশন সম্পন্ন করুন।',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => context.pushNamed(RouteNames.kycVerification),
                              child: Text(
                                'এখনই NID ভেরিফাই করুন →',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Top safety guarantee banner
              BariCard(
                backgroundColor: AppColors.primarySoft,
                borderColor: AppColors.primary.withAlpha(50),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anti-Broker Filter: All tenant applicants are verified with national ID (NID) and verified workplace credentials.',
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

              Text(
                'Applications Received (${_inquiries.length})',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // Loading State
              if (_isLoading && _inquiries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              // Error State
              else if (_errorMessage != null && _inquiries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withAlpha(60)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load applications',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: _fetchInquiries,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: const Text('Try Again', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              // Empty State
              else if (_inquiries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 64, color: AppColors.lightTextMuted),
                      const SizedBox(height: 16),
                      Text(
                        'No Applications In Inbox',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When prospective tenants submit inquiries or visit requests for your flats, they will appear here for verification and direct chat.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                )
              // Inquiries List from API
              else
                ..._inquiries.map((inquiry) {
                  final tenant = inquiry.tenant;
                  final tenantName = tenant?.fullName ?? 'Prospective Tenant';
                  final occupation = tenant?.occupation ?? 'Tenant';
                  final workplace = tenant?.workplace ?? 'Dhaka';
                  final familySize = tenant?.familyMembersCount ?? 1;
                  final isNidVerified = tenant?.isNidVerified ?? false;

                  final status = _localStatusOverrides[inquiry.id] ?? inquiry.status.toLowerCase();
                  final isPending = status == 'pending';

                  return BariCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with avatar, NID badge, and details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BariAvatar(
                              name: tenantName,
                              radius: 26,
                              isVerified: isNidVerified,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          tenantName,
                                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (isNidVerified)
                                        const BariBadge(
                                          type: BariBadgeType.nidVerified,
                                          isCompact: true,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$occupation at $workplace',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const BariRatingBar(rating: 5.0),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• Family Size: $familySize persons',
                                        style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Applied property & tenant message
                        Text(
                          'Inquiring for: ${inquiry.propertyTitle}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (inquiry.message.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '"${inquiry.message}"',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.lightTextPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Actions
                        if (isPending)
                          Row(
                            children: [
                              Expanded(
                                child: BariButton(
                                  label: 'Decline',
                                  variant: BariButtonVariant.outline,
                                  height: 40,
                                  onPressed: () => _onDecline(inquiry),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: BariButton(
                                  label: 'Accept & Chat',
                                  variant: BariButtonVariant.primary,
                                  height: 40,
                                  onPressed: () => _onAccept(inquiry),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: status == 'accepted' ? AppColors.successSoft : AppColors.errorSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      status == 'accepted'
                                          ? 'Application Accepted • Direct Masked Chat Open'
                                          : 'Application Declined',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: status == 'accepted' ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (status == 'accepted') ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                                  tooltip: 'Open Chat',
                                  onPressed: () {
                                    context.pushNamed(
                                      RouteNames.chatRoom,
                                      pathParameters: {'id': inquiry.id},
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
