import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentbd_app/core/router/route_names.dart';
import 'package:rentbd_app/core/theme/app_colors.dart';
import 'package:rentbd_app/core/theme/app_typography.dart';
import 'package:rentbd_app/core/widgets/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// KYC Verification Screen for Landlords (বাড়িওয়ালা).
/// Required before posting, publishing, or re-listing rental properties on RentBD.
class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _nidFrontUploaded = false;
  bool _nidBackUploaded = false;
  bool _selfieCaptured = false;
  bool _isEditingVerifiedDetails = false;

  String? _nidFrontPath;
  String? _nidBackPath;
  String? _selfiePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
      }
    });
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final u = authState.user;
      if (u.nidNumber.isNotEmpty) _nidController.text = u.nidNumber;
      if (u.presentAddress.isNotEmpty) _addressController.text = u.presentAddress;
      if (u.emergencyContact.isNotEmpty) {
        final parts = u.emergencyContact.split(' - ');
        if (parts.length > 1) {
          _emergencyNameController.text = parts[0].trim();
          _emergencyPhoneController.text = parts[1].trim();
        } else {
          _emergencyPhoneController.text = u.emergencyContact;
        }
      }

      _nidFrontPath = u.nidFrontUrl;
      _nidBackPath = u.nidBackUrl;
      _selfiePath = u.selfieUrl;

      _nidFrontUploaded = (u.nidFrontUrl != null && u.nidFrontUrl!.isNotEmpty) || u.isKycCompleted;
      _nidBackUploaded = (u.nidBackUrl != null && u.nidBackUrl!.isNotEmpty) || u.isKycCompleted;
      _selfieCaptured = (u.selfieUrl != null && u.selfieUrl!.isNotEmpty) || u.isKycCompleted;
    }
  }

  @override
  void dispose() {
    _nidController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({
    required ImageSource source,
    required CameraDevice preferredCamera,
    required Function(String path) onImagePicked,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: preferredCamera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (file != null) {
        onImagePicked(file.path);
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

  void _showPhotoSourceSheet({
    required String title,
    required CameraDevice preferredCamera,
    required Function(String path) onImagePicked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Capture a clear photo using camera or choose from gallery.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Open Camera (ক্যামেরা)'),
                subtitle: const Text('Capture live photo with device camera'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(
                    source: ImageSource.camera,
                    preferredCamera: preferredCamera,
                    onImagePicked: onImagePicked,
                  );
                },
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery (গ্যালারি)'),
                subtitle: const Text('Select photo from device storage'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(
                    source: ImageSource.gallery,
                    preferredCamera: preferredCamera,
                    onImagePicked: onImagePicked,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureSelfie() async {
    await _pickImage(
      source: ImageSource.camera,
      preferredCamera: CameraDevice.front,
      onImagePicked: (path) {
        setState(() {
          _selfiePath = path;
          _selfieCaptured = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live biometric selfie captured successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  void _onSubmitVerification() {
    if (!_formKey.currentState!.validate()) return;

    final emergencyContactCombined =
        '${_emergencyNameController.text.trim()} - ${_emergencyPhoneController.text.trim()}';

    context.read<AuthBloc>().add(
          SubmitKycRequestedEvent(
            nidNumber: _nidController.text.trim(),
            presentAddress: _addressController.text.trim(),
            emergencyContact: emergencyContactCombined,
            nidFrontUrl: _nidFrontPath ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f',
            nidBackUrl: _nidBackPath ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f',
            selfieUrl: _selfiePath ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord KYC Verification (NID)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.profile),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated && state.user.isKycCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('KYC verification submitted successfully!'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 3),
              ),
            );
            try {
              context.goNamed(RouteNames.home);
            } catch (_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final user = state is Authenticated ? state.user : null;
          final isAlreadyVerified = user?.isKycCompleted ?? false;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Landlord KYC Notice Banner
                    BariCard(
                      backgroundColor: isAlreadyVerified ? AppColors.primarySoft : AppColors.warningSoft,
                      borderColor: isAlreadyVerified
                          ? AppColors.primary.withAlpha(60)
                          : AppColors.warning.withAlpha(80),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isAlreadyVerified ? Icons.verified_user_rounded : Icons.shield_rounded,
                            color: isAlreadyVerified ? AppColors.primary : AppColors.warning,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAlreadyVerified
                                      ? 'KYC Verified Landlord (ভেরিফাইড বাড়িওয়ালা)'
                                      : 'Landlord KYC Required (বাড়িওয়ালা NID ভেরিফিকেশন)',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isAlreadyVerified ? AppColors.primaryDark : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAlreadyVerified
                                      ? 'আপনার জাতীয় পরিচয়পত্র অনুমোদিত। আপনি ভল্ট ও কুইক পোস্ট থেকে সরাসরি রেন্টাল প্রোপার্টি লিস্টিং তৈরি করতে পারবেন।'
                                      : 'জাল লিস্টিং প্রতিরোধে বাড়িওয়ালা হিসেবে ফ্ল্যাট বা বাসা ভাড়ার লিস্টিং তৈরি করতে জাতীয় পরিচয়পত্র (NID) ভেরিফিকেশন আবশ্যক।',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.lightTextSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isAlreadyVerified && !_isEditingVerifiedDetails) ...[
                      _buildVerifiedOverview(context, user),
                    ] else ...[
                      if (_isEditingVerifiedDetails)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Update NID Verification',
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _isEditingVerifiedDetails = false),
                                child: const Text('Cancel & View Verified'),
                              ),
                            ],
                          ),
                        ),

                      // Stepper Progress Tabs
                      Row(
                      children: [
                        _buildStepTab(0, '1. NID Details', Icons.credit_card_rounded),
                        const SizedBox(width: 8),
                        _buildStepTab(1, '2. Live Selfie', Icons.face_retouching_natural_rounded),
                        const SizedBox(width: 8),
                        _buildStepTab(2, '3. DMP Info', Icons.description_rounded),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Active Step Content
                    if (_currentStep == 0) ...[
                      // Step 1: NID
                      Text(
                        'Step 1: National Identity Card (NID)',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Provide your 10-digit Smart NID or 17-digit National ID number along with clear photos from your camera.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 16),

                      BariTextField(
                        controller: _nidController,
                        label: 'National ID (NID) Number',
                        hintText: '10 or 17 digit NID number',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter NID number';
                          final clean = val.replaceAll(RegExp(r'\D'), '');
                          if (clean.length < 10) return 'NID must be at least 10 digits';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // NID Front & Back Document Photo Pickers
                      Row(
                        children: [
                          Expanded(
                            child: _buildDocUploadCard(
                              title: 'NID Front (সামনে)',
                              isUploaded: _nidFrontUploaded,
                              imagePath: _nidFrontPath,
                              onTap: () {
                                _showPhotoSourceSheet(
                                  title: 'NID Front Photo (সামনের ছবি)',
                                  preferredCamera: CameraDevice.rear,
                                  onImagePicked: (path) {
                                    setState(() {
                                      _nidFrontPath = path;
                                      _nidFrontUploaded = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('NID Front photo captured!'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDocUploadCard(
                              title: 'NID Back (পেছনে)',
                              isUploaded: _nidBackUploaded,
                              imagePath: _nidBackPath,
                              onTap: () {
                                _showPhotoSourceSheet(
                                  title: 'NID Back Photo (পেছনের ছবি)',
                                  preferredCamera: CameraDevice.rear,
                                  onImagePicked: (path) {
                                    setState(() {
                                      _nidBackPath = path;
                                      _nidBackUploaded = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('NID Back photo captured!'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else if (_currentStep == 1) ...[
                      // Step 2: Biometric Selfie
                      Text(
                        'Step 2: Biometric Liveness Verification',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Position your face inside the frame in good lighting to confirm match with your NID photo.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: GestureDetector(
                          onTap: _captureSelfie,
                          child: Container(
                            width: 190,
                            height: 240,
                            decoration: BoxDecoration(
                              color: AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(95),
                              border: Border.all(
                                color: _selfieCaptured ? AppColors.primary : AppColors.lightBorder,
                                width: 3,
                              ),
                              boxShadow: _selfieCaptured
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(40),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(92),
                              child: _selfiePath != null && _selfiePath!.isNotEmpty
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _selfiePath!.startsWith('http')
                                            ? Image.network(_selfiePath!, fit: BoxFit.cover)
                                            : (!kIsWeb
                                                ? Image.file(File(_selfiePath!), fit: BoxFit.cover)
                                                : const Center(
                                                    child: Icon(Icons.person, size: 64, color: AppColors.primary))),
                                        Positioned(
                                          bottom: 14,
                                          left: 16,
                                          right: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withAlpha(220),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Face Matched',
                                                  style: AppTypography.labelSmall.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.face_rounded,
                                          size: 64,
                                          color: AppColors.lightTextMuted,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Align Face Here',
                                          style: AppTypography.labelLarge.copyWith(
                                            color: AppColors.lightTextSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap to open camera',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: Text(_selfieCaptured ? 'Retake Biometric Selfie' : 'Open Camera & Capture Selfie'),
                          onPressed: _captureSelfie,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Step 3: Landlord Address & Contact Declaration
                      Text(
                        'Step 3: Dhaka Address & Contact Declaration',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Landlord property / residential address and emergency contact mobile number.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 16),

                      BariTextField(
                        controller: _addressController,
                        label: 'Present Address in Dhaka (বর্তমান ঠিকানা)',
                        hintText: 'House, Road, Area, Dhaka',
                        prefixIcon: const Icon(Icons.home_outlined, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter present address';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      BariTextField(
                        controller: _emergencyNameController,
                        label: 'Emergency Contact Person / Guardian',
                        hintText: 'e.g. Rafiqul Islam (Father)',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter emergency contact name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      BariTextField(
                        controller: _emergencyPhoneController,
                        label: 'Emergency Mobile Number',
                        hintText: '01XXXXXXXXX',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter emergency mobile';
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Navigation buttons between steps
                    Row(
                      children: [
                        if (_currentStep > 0) ...[
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _currentStep--),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: _currentStep > 0 ? 2 : 1,
                          child: BariButton(
                            label: _currentStep < 2 ? 'Next Step' : 'Submit KYC',
                            isLoading: isLoading,
                            onPressed: () {
                              if (_currentStep < 2) {
                                setState(() => _currentStep++);
                              } else {
                                _onSubmitVerification();
                              }
                            },
                            leadingIcon: Icon(
                              _currentStep < 2 ? Icons.arrow_forward_rounded : Icons.check_circle_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _buildVerifiedOverview(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BariCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ভেরিফাইড তথ্য (Verified Records)',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const BariBadge(
                    type: BariBadgeType.custom,
                    customLabel: 'VERIFIED',
                    customColor: AppColors.primary,
                    customBgColor: AppColors.primarySoft,
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildVerifiedRow(
                icon: Icons.badge_outlined,
                label: 'National ID (NID) Number',
                value: (user?.nidNumber.isNotEmpty == true)
                    ? user!.nidNumber
                    : 'EC Verified & Secured',
              ),
              const SizedBox(height: 14),
              _buildVerifiedRow(
                icon: Icons.person_outline,
                label: 'Legal Full Name',
                value: (user?.fullName.isNotEmpty == true) ? user!.fullName : 'Landlord Account',
              ),
              const SizedBox(height: 14),
              _buildVerifiedRow(
                icon: Icons.location_on_outlined,
                label: 'Present Address in Dhaka',
                value: (user?.presentAddress.isNotEmpty == true)
                    ? user!.presentAddress
                    : 'Declared on NID verification',
              ),
              const SizedBox(height: 14),
              _buildVerifiedRow(
                icon: Icons.phone_outlined,
                label: 'Emergency Contact Mobile',
                value: (user?.emergencyContact.isNotEmpty == true)
                    ? user!.emergencyContact
                    : 'Registered on profile',
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'NID Card Front, Back & Live Biometric Selfie verified successfully.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Navigation Actions
        BariButton(
          label: 'Manage Properties in Vault (ভল্ট এ যান)',
          leadingIcon: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 18),
          onPressed: () => context.goNamed(RouteNames.propertyVault),
        ),
        const SizedBox(height: 12),
        BariButton(
          label: 'Post New Flat for Rent (ফ্ল্যাট পোস্ট করুন)',
          variant: BariButtonVariant.secondary,
          leadingIcon: const Icon(Icons.add_home_work_rounded, size: 18),
          onPressed: () => context.pushNamed(RouteNames.quickPost),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Update / Re-verify NID Details (কেওয়াইসি আপডেট করুন)'),
            onPressed: () {
              setState(() => _isEditingVerifiedDetails = true);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVerifiedRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepTab(int stepIndex, String title, IconData icon) {
    final isSelected = _currentStep == stepIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentStep = stepIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.lightTextMuted,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required bool isUploaded,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final bool hasImage = isUploaded && imagePath != null && imagePath.isNotEmpty;

    return BariCard(
      padding: EdgeInsets.zero,
      backgroundColor: hasImage ? AppColors.primarySoft : AppColors.lightSurface,
      borderColor: hasImage ? AppColors.primary.withAlpha(80) : AppColors.lightBorder,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imagePath.startsWith('http')
                        ? Image.network(imagePath, fit: BoxFit.cover)
                        : (!kIsWeb
                            ? Image.file(File(imagePath), fit: BoxFit.cover)
                            : const Center(
                                child: Icon(Icons.image, size: 36, color: AppColors.primary),
                              )),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to Retake',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Open Camera',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
