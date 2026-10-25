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
import '../../../property/domain/entities/property.dart';
import '../../../property/domain/repositories/property_repository.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/bloc/property_event.dart';
import '../../../property/presentation/bloc/property_state.dart';

/// Landlord Property Vault: 1-Tap Re-Listing and Automated Availability Check.
class PropertyVaultScreen extends StatefulWidget {
  const PropertyVaultScreen({super.key});

  @override
  State<PropertyVaultScreen> createState() => _PropertyVaultScreenState();
}

class _PropertyVaultScreenState extends State<PropertyVaultScreen> {
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _togglingIds = {};

  @override
  void initState() {
    super.initState();
    final propertyState = context.read<PropertyBloc>().state;
    if (propertyState is PropertyLoaded && propertyState.properties.isNotEmpty) {
      _properties = propertyState.properties;
      _isLoading = false;
    }
    _fetchProperties();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
        context.read<PropertyBloc>().add(const FetchPropertiesEvent(isRefresh: true));
      }
    });
  }

  Future<void> _onRefresh() async {
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    context.read<PropertyBloc>().add(const FetchPropertiesEvent(isRefresh: true));
    await _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final properties = await sl<PropertyRepository>().getProperties();
      if (!mounted) return;
      setState(() {
        _properties = properties;
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

  Future<void> _onToggleVault(Property item) async {
    if (_togglingIds.contains(item.id)) return;

    final authState = context.read<AuthBloc>().state;
    final isKycCompleted = authState is Authenticated && authState.user.isKycCompleted;

    if (!isKycCompleted) {
      _showLandlordKycRequiredDialog(context);
      return;
    }

    // A listing under admin review cannot be made publicly available until approved
    if (item.isPendingReview) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This property is under Admin Review. It will become available once approved by admin.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final index = _properties.indexWhere((p) => p.id == item.id);
    if (index == -1) return;

    final originalProperty = _properties[index];
    final targetAvailable = !originalProperty.isAvailable;

    // 1. Instant optimistic instance update so switch immediately moves
    setState(() {
      _properties[index] = originalProperty.copyWith(
        isAvailable: targetAvailable,
      );
      _togglingIds.add(item.id);
    });

    try {
      final isVaulted = await sl<PropertyRepository>().toggleVault(item.id);
      final currentIndex = _properties.indexWhere((p) => p.id == item.id);
      if (currentIndex != -1) {
        setState(() {
          _properties[currentIndex] = _properties[currentIndex].copyWith(
            isAvailable: !isVaulted,
          );
        });
      }

      if (mounted) {
        context.read<PropertyBloc>().add(const FetchPropertiesEvent(isRefresh: true));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isVaulted
                ? 'Flat re-published live to tenants in 1 tap!'
                : 'Flat marked as rented and safely stored in Vault.',
          ),
          backgroundColor: !isVaulted ? AppColors.success : AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Revert instance back on error
      if (mounted) {
        final currentIndex = _properties.indexWhere((p) => p.id == item.id);
        if (currentIndex != -1) {
          setState(() {
            _properties[currentIndex] = originalProperty;
          });
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${RentBdErrorFormatter.format(e)}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _togglingIds.remove(item.id));
      }
    }
  }

  Future<void> _onAdminApprove(Property item) async {
    setState(() => _togglingIds.add(item.id));
    try {
      final updated = await sl<PropertyRepository>().updatePropertyStatus(item.id, 'active');
      final index = _properties.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        setState(() {
          _properties[index] = updated;
        });
      }
      if (mounted) {
        context.read<PropertyBloc>().add(const FetchPropertiesEvent(isRefresh: true));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Listing "${item.title}" approved by Admin and is now live!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approval failed: ${RentBdErrorFormatter.format(e)}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _togglingIds.remove(item.id));
      }
    }
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
                      'KYC সম্পন্ন না করা পর্যন্ত আপনি নতুন লিস্টিং প্রকাশ করতে পারবেন না।',
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
        content: Text('প্রোপার্টি তৈরি ও রিলিস্টিং করতে আগে NID ভেরিফিকেশন (KYC) সম্পন্ন করুন।'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isKycCompleted = authState is Authenticated ? authState.user.isKycCompleted : false;

    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertyLoaded) {
          setState(() {
            _properties = state.properties;
            _isLoading = false;
            _errorMessage = null;
          });
        } else if (state is PropertyError && _properties.isEmpty) {
          setState(() {
            _errorMessage = state.message;
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Property Vault (Re-Listing)'),
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Properties',
              onPressed: _onRefresh,
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_home_work_rounded, color: Colors.white),
        label: Text(
          'Post New Property (ফ্ল্যাট যোগ করুন)',
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () async {
          if (!isKycCompleted) {
            _showLandlordKycRequiredDialog(context);
          } else {
            final result = await context.pushNamed(RouteNames.quickPost);
            if (result == true || mounted) {
              _fetchProperties();
            }
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                              'নতুন ফ্ল্যাট লিস্টিং তৈরি ও পাবলিশ করতে NID ভেরিফিকেশন সম্পন্ন করুন।',
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

              // Explanatory Banner
              BariCard(
                backgroundColor: AppColors.primarySoft,
                borderColor: AppColors.primary.withAlpha(50),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Never re-type listing descriptions or re-take photos. Toggle flats between "Rented" and "Available" in 1 tap.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'My Managed Properties',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // Loading State
              if (_isLoading && _properties.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              // Error State
              else if (_errorMessage != null && _properties.isEmpty)
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
                        'Failed to load properties',
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
                        onPressed: _fetchProperties,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: const Text('Try Again', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              // Empty State
              else if (_properties.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_work_outlined, size: 64, color: AppColors.lightTextMuted),
                      const SizedBox(height: 16),
                      Text(
                        'No Properties In Vault',
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have not added any properties to your vault yet. Tap "Post New Property" below to add your first flat!',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 20),
                      BariButton(
                        label: 'Post First Property (ফ্ল্যাট যোগ করুন)',
                        leadingIcon: const Icon(Icons.add_home_work_rounded, color: Colors.white),
                        onPressed: () async {
                          if (!isKycCompleted) {
                            _showLandlordKycRequiredDialog(context);
                          } else {
                            final result = await context.pushNamed(RouteNames.quickPost);
                            if (result == true || mounted) {
                              _fetchProperties();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                )
              // Properties List
              else
                ..._properties.map((item) {
                  final imageUrl = item.images.isNotEmpty
                      ? item.images.first.imageUrl
                      : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800';
                  final isToggling = _togglingIds.contains(item.id);

                  return BariCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    onTap: () {
                      context.pushNamed(
                        RouteNames.propertyDetail,
                        pathParameters: {'id': item.id},
                        extra: item,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BariImage(
                              imageUrl: imageUrl,
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(10),
                              placeholderIcon: Icons.home_work_rounded,
                              placeholderColor: AppColors.lightBackground,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (item.isPendingReview)
                                        const BariBadge(
                                          type: BariBadgeType.underReview,
                                          isCompact: true,
                                        )
                                      else ...[
                                        const BariBadge(
                                          type: BariBadgeType.approved,
                                          isCompact: true,
                                        ),
                                        BariBadge(
                                          type: item.isAvailable ? BariBadgeType.available : BariBadgeType.rented,
                                          isCompact: true,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title,
                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.areaNeighborhood,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  BariPriceTag(
                                    amount: item.rentAmount,
                                    size: BariPriceSize.compact,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Automated verification status & 1-tap re-listing switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (item.isPendingReview) ...[
                                  const Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Under Admin Review (অ্যাডমিন পর্যালোচনা)',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: isToggling ? null : () => _onAdminApprove(item),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.primary.withAlpha(80)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Approve',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else if (item.isApproved) ...[
                                  const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Admin Approved (অনুমোদিত)',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Rejected by Admin (বাতিল)',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                if (isToggling) ...[
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  item.isPendingReview
                                      ? 'Awaiting Approval'
                                      : (item.isAvailable ? 'Mark Rented' : 'Mark Available'),
                                  style: AppTypography.labelMedium.copyWith(
                                    color: item.isPendingReview
                                        ? AppColors.secondary
                                        : (!item.isAvailable ? AppColors.primary : AppColors.lightTextMuted),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: item.isAvailable,
                                  activeTrackColor: AppColors.primary,
                                  onChanged: isToggling
                                      ? null
                                      : (val) {
                                          if (item.isPendingReview) {
                                            _onToggleVault(item);
                                            return;
                                          }
                                          if (val && !isKycCompleted) {
                                            _showLandlordKycRequiredDialog(context);
                                            return;
                                          }
                                          _onToggleVault(item);
                                        },
                                ),
                              ],
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
      ),
    ),
  );
}
}

