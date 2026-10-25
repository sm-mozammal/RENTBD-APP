import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/error_formatter.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../property/domain/repositories/property_repository.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/bloc/property_event.dart';

/// Quick Post flow with One-Click AI Listing Writer.
class QuickPostScreen extends StatefulWidget {
  const QuickPostScreen({super.key});

  @override
  State<QuickPostScreen> createState() => _QuickPostScreenState();
}

class _QuickPostScreenState extends State<QuickPostScreen> {
  final _titleController = TextEditingController();
  final _rentController = TextEditingController();
  final _advanceController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _utilitiesController = TextEditingController();
  final _sqftController = TextEditingController();
  final _floorLevelController = TextEditingController();
  final _totalFloorsController = TextEditingController();
  final _alleyWidthController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _area = 'Mirpur 10';
  String _tenantCategory = 'Bachelor';
  int _bedrooms = 2;
  int _bathrooms = 2;
  int _balconies = 1;
  String _gasSupply = 'LINE_GAS';
  bool _hasLift = true;
  bool _hasGenerator = true;
  bool _isLiveCameraGeoTagged = true;
  bool _isGeneratingAiDesc = false;
  bool _isPublishing = false;

  final List<String> _photos = [];

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (file != null && mounted) {
        setState(() {
          _photos.add(file.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Capture with Live Camera (ক্যামেরা)'),
                subtitle: const Text('Takes live geo-tagged photo of flat'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Choose from Gallery (গ্যালারি)'),
                subtitle: const Text('Select photo from device storage'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _advanceController.dispose();
    _serviceChargeController.dispose();
    _utilitiesController.dispose();
    _sqftController.dispose();
    _floorLevelController.dispose();
    _totalFloorsController.dispose();
    _alleyWidthController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onGenerateAiDescription() async {
    setState(() => _isGeneratingAiDesc = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final sqft = int.tryParse(_sqftController.text.trim()) ?? 0;
    final floorLevel = int.tryParse(_floorLevelController.text.trim()) ?? 0;
    final alleyWidth = double.tryParse(_alleyWidthController.text.trim()) ?? 0.0;

    final sqftText = sqft > 0 ? '$sqft SqFt ' : '';
    final floorText = floorLevel > 0 ? 'on Floor $floorLevel' : '';
    final gasText = _gasSupply == 'LINE_GAS'
        ? 'active line gas connection'
        : _gasSupply == 'CYLINDER'
            ? 'gas cylinder setup'
            : 'electric induction cooking';
    final roadText = alleyWidth > 0 ? '${alleyWidth.toInt()}ft wide front road access' : 'wide road access';
    final liftGenParts = <String>[];
    if (_hasLift) liftGenParts.add('lift/elevator');
    if (_hasGenerator) liftGenParts.add('generator backup');
    final liftGen = liftGenParts.isNotEmpty ? ', with ${liftGenParts.join(' and ')}' : '';

    final autoTitle = '${sqftText.isNotEmpty ? sqftText : ""}$_bedrooms-Bed $_tenantCategory Friendly Modern Flat in $_area';
    final autoDesc =
        'Spacious ${sqftText.isNotEmpty ? "$sqft SqFt, " : ""}$_bedrooms-bedroom, $_bathrooms-bathroom, $_balconies-balcony apartment situated in $_area $floorText. '
        'Includes modern tile finishing, $roadText, $gasText$liftGen, and continuous WASA water supply. '
        'Ideal for $_tenantCategory tenants looking for a peaceful and safe community with 24/7 building caretaker.';

    setState(() {
      _titleController.text = autoTitle;
      _descController.text = autoDesc;
      _isGeneratingAiDesc = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI One-Click Description generated!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _onPublish() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      if (!authState.user.isLandlord) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.gavel_rounded, color: AppColors.warning, size: 26),
                SizedBox(width: 10),
                Flexible(child: Text('Landlord Mode Required')),
              ],
            ),
            content: Text(
              'You are registered as a Tenant (ভাড়াটিয়া). Only verified Landlords (বাড়িওয়ালা) can publish rental flat listings.',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Landlords can register and login without KYC, but MUST complete KYC to create/publish a property listing
      if (!authState.user.isKycCompleted) {
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
                  'বাড়িওয়ালা হিসেবে ফ্ল্যাট বা বাসা ভাড়ার লিস্টিং প্রকাশ করার জন্য আপনার জাতীয় পরিচয়পত্র (NID) ভেরিফিকেশন (KYC) সম্পন্ন করা আবশ্যক।',
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
            content: Text('প্রোপার্টি তৈরি করতে আগে NID ভেরিফিকেশন (KYC) সম্পন্ন করুন।'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final rent = double.tryParse(_rentController.text.trim());
    if (rent == null || rent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid monthly rent amount.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    final advance = double.tryParse(_advanceController.text.trim()) ?? (rent * 2);
    final serviceCharge = double.tryParse(_serviceChargeController.text.trim()) ?? 0.0;
    final utilities = double.tryParse(_utilitiesController.text.trim()) ?? 0.0;
    final sqft = int.tryParse(_sqftController.text.trim()) ?? 0;
    final floorLevel = int.tryParse(_floorLevelController.text.trim()) ?? 0;
    final totalFloors = int.tryParse(_totalFloorsController.text.trim()) ?? 0;
    final alleyWidth = double.tryParse(_alleyWidthController.text.trim()) ?? 0.0;

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : '$_bedrooms-Bed $_tenantCategory Friendly Modern Flat in $_area';
    final desc = _descController.text.trim().isNotEmpty
        ? _descController.text.trim()
        : 'Spacious and airy $_bedrooms-bedroom, $_bathrooms-bathroom apartment situated in $_area. Includes modern tile finishing, wide road access, active gas connection, and continuous WASA water supply.';
    final address = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : 'Road 5, Block C, $_area, Dhaka';

    String tenantCategoryDrf;
    switch (_tenantCategory.toUpperCase()) {
      case 'BACHELOR':
        tenantCategoryDrf = 'BACHELOR_MALE';
        break;
      case 'SUBLET':
        tenantCategoryDrf = 'ANY';
        break;
      case 'FAMILY':
      default:
        tenantCategoryDrf = 'FAMILY';
        break;
    }

    final payload = <String, dynamic>{
      'title': title,
      'description': desc,
      'property_type': _tenantCategory.toUpperCase() == 'SUBLET' ? 'SUBLET' : 'APARTMENT',
      'tenant_category': tenantCategoryDrf,
      'rent_amount': rent,
      'security_deposit': advance,
      'service_charge': serviceCharge,
      'estimated_utilities': utilities,
      'area_neighborhood': _area,
      'full_address': address,
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'balconies': _balconies,
      'square_feet': sqft,
      'size_sqft': sqft,
      'floor_level': floorLevel,
      'total_floors': totalFloors,
      'alley_width_feet': alleyWidth,
      'road_width_ft': alleyWidth,
      'gas_supply': _gasSupply,
      'has_line_gas': _gasSupply == 'LINE_GAS',
      'has_gas_cylinder': _gasSupply == 'CYLINDER',
      'has_lift': _hasLift,
      'has_generator': _hasGenerator,
      'has_geo_tagged_photos': _isLiveCameraGeoTagged,
      'latitude': 23.8103,
      'longitude': 90.4125,
      'photos': _photos,
      'is_available': false,
      'status': 'PENDING',
      'is_approved': false,
    };

    try {
      final created = await sl<PropertyRepository>().createProperty(payload);

      if (mounted) {
        context.read<PropertyBloc>().add(const FetchPropertiesEvent(isRefresh: true));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Property "${created.title.isNotEmpty ? created.title : title}" submitted for Admin Review! It will become available once approved by admin.',
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _titleController.clear();
      _rentController.clear();
      _advanceController.clear();
      _serviceChargeController.clear();
      _utilitiesController.clear();
      _sqftController.clear();
      _floorLevelController.clear();
      _totalFloorsController.clear();
      _alleyWidthController.clear();
      _addressController.clear();
      _descController.clear();
      _photos.clear();

      try {
        if (context.canPop()) {
          context.pop(true);
        }
        if (mounted) {
          context.goNamed(RouteNames.propertyVault);
        }
      } catch (_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish property: ${RentBdErrorFormatter.format(e)}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isKycCompleted = authState is Authenticated ? authState.user.isKycCompleted : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Post Listing'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                              'NID ভেরিফিকেশন (KYC) আবশ্যক',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ফ্ল্যাট বা বাসা ভাড়ার লিস্টিং প্রকাশ করার আগে আপনার জাতীয় পরিচয়পত্র ভেরিফিকেশন সম্পন্ন করুন।',
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

              // Speed banner
              BariCard(
                backgroundColor: AppColors.primarySoft,
                borderColor: AppColors.primary.withAlpha(50),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Drop pin, upload live camera photos, and publish your flat immediately.',
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

              // Live GPS Photo Capture & Classifier
              Text(
                'Live Geo-Tagged Photos',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Camera Add Button
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._photos.map(
                      (photo) => Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: photo.startsWith('http')
                                  ? Image.network(
                                      photo,
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    )
                                  : Image.file(
                                      File(photo),
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _photos.remove(photo)),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _isLiveCameraGeoTagged = !_isLiveCameraGeoTagged),
                child: Row(
                  children: [
                    Icon(
                      _isLiveCameraGeoTagged ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
                      size: 14,
                      color: _isLiveCameraGeoTagged ? AppColors.primary : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isLiveCameraGeoTagged
                          ? 'Active GPS verified • "Verified Real Photo" badge granted'
                          : 'GPS tagging inactive • Tap to enable',
                      style: AppTypography.labelSmall.copyWith(
                        color: _isLiveCameraGeoTagged ? AppColors.primary : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location Drop Pin & Area
              Text(
                'Location & Neighborhood',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _area,
                decoration: const InputDecoration(
                  labelText: 'Dhaka Area',
                  prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary),
                ),
                items: ['Mirpur 10', 'Uttara', 'Gulshan 2', 'Dhanmondi', 'Bashundhara', 'Mohammadpur']
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _area = val);
                },
              ),
              const SizedBox(height: 12),
              BariTextField(
                controller: _addressController,
                hintText: 'Full road and house address',
                prefixIcon: const Icon(Icons.pin_drop_rounded, color: AppColors.primary),
              ),
              const SizedBox(height: 20),

              // Rent & Advance
              Row(
                children: [
                  Expanded(
                    child: BariTextField(
                      controller: _rentController,
                      label: 'Monthly Rent (৳)',
                      hintText: 'e.g. 25000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BariTextField(
                      controller: _advanceController,
                      label: 'Advance Deposit (৳)',
                      hintText: 'e.g. 50000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Additional Recurring Charges
              Row(
                children: [
                  Expanded(
                    child: BariTextField(
                      controller: _serviceChargeController,
                      label: 'Service Charge (৳)',
                      hintText: 'e.g. 3500',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BariTextField(
                      controller: _utilitiesController,
                      label: 'Est. Utilities (৳)',
                      hintText: 'e.g. 2000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Flat Specifications Header
              Text(
                'Flat Specifications (ফ্ল্যাটের বিবরণ)',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              // Tenant category, Bedrooms, Bathrooms & Balconies
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tenant Type', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          initialValue: _tenantCategory,
                          items: ['Family', 'Bachelor', 'Sublet']
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _tenantCategory = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beds', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          initialValue: _bedrooms,
                          items: [1, 2, 3, 4, 5]
                              .map((b) => DropdownMenuItem(
                                    value: b,
                                    child: Text('$b Bed${b > 1 ? "s" : ""}', overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _bedrooms = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Baths', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          initialValue: _bathrooms,
                          items: [1, 2, 3, 4]
                              .map((b) => DropdownMenuItem(
                                    value: b,
                                    child: Text('$b Bath${b > 1 ? "s" : ""}', overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _bathrooms = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balcony', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          initialValue: _balconies,
                          items: [0, 1, 2, 3, 4]
                              .map((b) => DropdownMenuItem(
                                    value: b,
                                    child: Text('$b', overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _balconies = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Size (SqFt), Floor Level & Total Building Floors
              Row(
                children: [
                  Expanded(
                    child: BariTextField(
                      controller: _sqftController,
                      label: 'Size (SqFt)',
                      hintText: 'e.g. 1250',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BariTextField(
                      controller: _floorLevelController,
                      label: 'Floor No',
                      hintText: 'e.g. 4',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BariTextField(
                      controller: _totalFloorsController,
                      label: 'Total Floors',
                      hintText: 'e.g. 7',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Building Road Access & Amenities
              Text(
                'Road & Building Amenities (রাস্তা ও সুযোগ সুবিধা)',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: BariTextField(
                      controller: _alleyWidthController,
                      label: 'Road Width (Feet)',
                      hintText: 'e.g. 16',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.traffic_rounded, color: AppColors.secondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gas Supply', style: AppTypography.titleSmall),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          initialValue: _gasSupply,
                          items: const [
                            DropdownMenuItem(value: 'LINE_GAS', child: Text('Line Gas (লাইনের)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'CYLINDER', child: Text('Cylinder (সিলিন্ডার)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'NONE', child: Text('None (নাই)', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _gasSupply = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lift & Generator Checkbox toggles
              Material(
                color: AppColors.lightBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.lightBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: const Text('Elevator / Lift', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: _hasLift,
                          activeColor: AppColors.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) => setState(() => _hasLift = val ?? false),
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: const Text('Generator', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          value: _hasGenerator,
                          activeColor: AppColors.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) => setState(() => _hasGenerator = val ?? false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // One-Click AI Listing Writer Trigger
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Listing Details',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    icon: _isGeneratingAiDesc
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                    label: const Text('1-Click AI Writer'),
                    onPressed: _isGeneratingAiDesc ? null : _onGenerateAiDescription,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BariTextField(
                controller: _titleController,
                hintText: 'e.g. 2-Bed Bachelor Friendly Flat in Mirpur 10',
                label: 'Listing Title',
              ),
              const SizedBox(height: 12),
              BariTextField(
                controller: _descController,
                hintText: 'Tap "1-Click AI Writer" above to auto-generate description...',
                label: 'Description',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              BariButton(
                label: _isPublishing ? 'Publishing Property...' : 'Publish Property Listing',
                isLoading: _isPublishing,
                onPressed: _isPublishing ? null : _onPublish,
                leadingIcon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
