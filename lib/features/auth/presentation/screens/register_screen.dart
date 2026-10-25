import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rentbd_app/core/router/route_names.dart';
import 'package:rentbd_app/core/theme/app_colors.dart';
import 'package:rentbd_app/core/theme/app_typography.dart';
import 'package:rentbd_app/core/widgets/widgets.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Next-Generation Registration Screen for RentBD.
/// Features:
/// - Visual Role Selection Cards (Tenant vs Landlord)
/// - Bangladeshi Phone Number formatting (+880) & Operator Validation
/// - Live Password Strength Meter with requirement chips
/// - DMP Police Tenant Verification Compliance Agreement
/// - Clean Architecture BLoC Integration with direct zero-rework contract
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.tenant;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;

  // Password strength calculation
  int _passwordStrength = 0; // 0 = empty, 1 = weak, 2 = medium, 3 = strong
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evalPasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_evalPasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evalPasswordStrength() {
    final pwd = _passwordController.text;
    final minLength = pwd.length >= 6;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(pwd);
    final hasNumber = RegExp(r'[0-9]').hasMatch(pwd);

    int score = 0;
    if (minLength) score++;
    if (hasLetter) score++;
    if (hasNumber) score++;

    setState(() {
      _hasMinLength = minLength;
      _hasLetter = hasLetter;
      _hasNumber = hasNumber;
      _passwordStrength = pwd.isEmpty ? 0 : score;
    });
  }

  String _formatToBdPhone(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('880')) {
      return '+$clean';
    } else if (clean.startsWith('0')) {
      return '+88$clean';
    } else if (clean.isNotEmpty) {
      return '+880$clean';
    }
    return '';
  }

  bool _isValidBdPhone(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 11 && clean.startsWith('01')) {
      return true;
    }
    if (clean.length == 13 && clean.startsWith('8801')) {
      return true;
    }
    return false;
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'দয়া করে RentBD ব্যবহার শর্তাবলী ও DMP গাইডলাইনে সম্মতি দিন।',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final rawPhone = _phoneController.text.trim();
    if (!_isValidBdPhone(rawPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: 017XXXXXXXX)',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final formattedPhone = _formatToBdPhone(rawPhone);

    context.read<AuthBloc>().add(
          RegisterRequestedEvent(
            fullName: _nameController.text.trim(),
            phoneNumber: formattedPhone,
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLandlord = _selectedRole == UserRole.landlord;
    final primaryColor = isLandlord ? AppColors.secondary : AppColors.primary;
    final primarySoftColor = isLandlord ? AppColors.secondarySoft : AppColors.primarySoft;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'নতুন অ্যাকাউন্ট তৈরি করুন',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.login);
            }
          },
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.user.isLandlord
                      ? 'স্বাগতম বাড়িওয়ালা ${state.user.fullName}! আপনার অ্যাকাউন্ট প্রস্তুত।'
                      : 'স্বাগতম ভাড়াটিয়া ${state.user.fullName}! RentBD-তে অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে।',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Users register and enter without forced KYC
            if (state.user.isLandlord) {
              context.goNamed(RouteNames.propertyVault);
            } else {
              context.goNamed(RouteNames.home);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Welcoming Header
                    _buildHeaderBanner(primaryColor),
                    const SizedBox(height: 24),

                    // Role Selection Title
                    Text(
                      'Select Account Type / আপনি কি হিসেবে যুক্ত হতে চান?',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Role Cards (Tenant vs Landlord)
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            role: UserRole.tenant,
                            title: 'ভাড়াটিয়া (Tenant)',
                            subtitle: 'বাসা খোঁজার জন্য',
                            icon: Icons.person_pin_circle_rounded,
                            badgeText: '0% Broker Fee',
                            isSelected: !isLandlord,
                            cardColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard(
                            role: UserRole.landlord,
                            title: 'বাড়িওয়ালা (Owner)',
                            subtitle: 'ফ্ল্যাট ভাড়া দিতে',
                            icon: Icons.apartment_rounded,
                            badgeText: 'Smart Vault',
                            isSelected: isLandlord,
                            cardColor: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Role-Specific DMP Guidance Card
                    _buildRoleNotice(isLandlord, primaryColor, primarySoftColor),
                    const SizedBox(height: 24),

                    // Input: Full Name
                    BariTextField(
                      controller: _nameController,
                      label: 'Full Name (পূর্ণ নাম)',
                      hintText: 'e.g. Tanvir Hasan',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: primaryColor),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'আপনার পূর্ণ নাম লিখুন';
                        }
                        if (val.trim().length < 3) {
                          return 'নাম কমপক্ষে ৩ অক্ষরের হতে হবে';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input: Bangladeshi Mobile Number
                    _buildPhoneInputField(primaryColor),
                    const SizedBox(height: 16),

                    // Input: Email Address (Optional / Recommended)
                    BariTextField(
                      controller: _emailController,
                      label: 'Email Address (ইমেইল ঠিকানা - ঐচ্ছিক)',
                      hintText: 'e.g. tanvir@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          if (!val.contains('@') || !val.contains('.')) {
                            return 'সঠিক ইমেইল ঠিকানা দিন';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input: Password
                    BariTextField(
                      controller: _passwordController,
                      label: 'Password (পাসওয়ার্ড)',
                      hintText: 'কমপক্ষে ৬ ডিজিটের পাসওয়ার্ড',
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.lightTextMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Interactive Password Strength Bar
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 16),

                    // Input: Confirm Password
                    BariTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password (পাসওয়ার্ড নিশ্চিত করুন)',
                      hintText: 'পুনরায় পাসওয়ার্ড লিখুন',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icon(Icons.lock_reset_rounded, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.lightTextMuted,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'পাসওয়ার্ড দুটি মেলেনি';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Terms and DMP Compliance Checkbox
                    _buildTermsCheckbox(primaryColor),
                    const SizedBox(height: 24),

                    // Submit Registration Button
                    BariButton(
                      label: isLandlord
                          ? 'Register as Landlord & Enter Vault'
                          : 'Register as Tenant & Proceed (রেজিস্ট্রেশন)',
                      isLoading: isLoading,
                      variant: isLandlord
                          ? BariButtonVariant.secondary
                          : BariButtonVariant.primary,
                      leadingIcon: const Icon(
                        Icons.app_registration_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      onPressed: _onRegister,
                    ),
                    const SizedBox(height: 24),

                    // Already have an account? Sign In
                    _buildSignInPrompt(primaryColor),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Header with Brand Mark and Welcoming Text
  Widget _buildHeaderBanner(Color primaryColor) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withAlpha(200)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join RentBD Today',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'সরাসরি মালিকদের সাথে ভাড়া - কোনো ব্রোকার ফি নেই',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Interactive Role Card
  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required bool isSelected,
    required Color cardColor,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? cardColor.withAlpha(12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cardColor : AppColors.lightBorder,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? cardColor.withAlpha(30) : Colors.black.withAlpha(6),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? cardColor : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? cardColor : AppColors.lightBorder,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? cardColor : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? cardColor.withAlpha(30) : AppColors.lightDivider,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? cardColor : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Role Guidance & DMP Compliance Notice Banner
  Widget _buildRoleNotice(bool isLandlord, Color primaryColor, Color primarySoftColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLandlord ? AppColors.secondarySoft.withAlpha(120) : AppColors.primarySoft.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLandlord ? AppColors.secondary.withAlpha(70) : AppColors.primary.withAlpha(70),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isLandlord ? Icons.verified_user_rounded : Icons.shield_rounded,
            color: primaryColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLandlord
                  ? 'বাড়িওয়ালা সুবিধা: সহজে অ্যাকাউন্ট তৈরি করুন। পরবর্তীতে ফ্ল্যাট বা বাসা রেন্ট পোস্ট করতে আপনার প্রোফাইল থেকে NID ভেরিফিকেশন (KYC) সম্পন্ন করতে পারবেন।'
                  : 'ভাড়াটিয়া সুবিধা: সরাসরি ভেরিফাইড ফ্ল্যাট মালিকদের সাথে যোগাযোগ করুন এবং সম্পূর্ণ ব্রোকার ফি মুক্ত নিরাপদ বাসা ভাড়া নিশ্চিত করুন।',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.lightTextPrimary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Phone input with BD 🇧🇩 prefix
  Widget _buildPhoneInputField(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number (মোবাইল নম্বর)',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightBorder, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.lightDivider.withAlpha(140),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    bottomLeft: Radius.circular(13),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇧🇩', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '+880',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                  decoration: InputDecoration(
                    hintText: '17XXXXXXXX',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.lightTextMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'মোবাইল নম্বর লিখুন';
                    }
                    if (!_isValidBdPhone(val)) {
                      return 'সঠিক ১১ ডিজিটের নম্বর দিন (017...)';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Real-Time Password Strength Meter
  Widget _buildPasswordStrengthIndicator() {
    Color getStrengthColor() {
      switch (_passwordStrength) {
        case 1:
          return AppColors.error;
        case 2:
          return AppColors.warning;
        case 3:
          return AppColors.success;
        default:
          return AppColors.lightDivider;
      }
    }

    String getStrengthText() {
      switch (_passwordStrength) {
        case 1:
          return 'Weak (দুর্বল)';
        case 2:
          return 'Good (মোটামুটি)';
        case 3:
          return 'Strong (শক্তিশালী)';
        default:
          return 'পাসওয়ার্ড শক্তি';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _passwordStrength / 3.0,
                  backgroundColor: AppColors.lightDivider,
                  valueColor: AlwaysStoppedAnimation<Color>(getStrengthColor()),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              getStrengthText(),
              style: AppTypography.labelSmall.copyWith(
                color: getStrengthColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildRequirementChip('৬+ অক্ষর', _hasMinLength),
            const SizedBox(width: 8),
            _buildRequirementChip('অক্ষর (A-Z)', _hasLetter),
            const SizedBox(width: 8),
            _buildRequirementChip('সংখ্যা (0-9)', _hasNumber),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirementChip(String label, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
          size: 13,
          color: isMet ? AppColors.success : AppColors.lightTextMuted,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 10,
            color: isMet ? AppColors.lightTextPrimary : AppColors.lightTextMuted,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Terms & Compliance Checkbox
  Widget _buildTermsCheckbox(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _agreedToTerms,
            activeColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
          ),
          Expanded(
            child: Text(
              'আমি RentBD শর্তাবলী, গোপনীয়তা নীতি এবং ঢাকা মেট্রোপলিটন পুলিশ নিরাপত্তা বিধি (DMP) মেনে চলতে সম্মত।',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.lightTextSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Prompt to navigate back to sign-in
  Widget _buildSignInPrompt(Color primaryColor) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.lightTextSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.login),
            child: Text(
              'Sign In via OTP (লগইন)',
              style: AppTypography.bodyMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
