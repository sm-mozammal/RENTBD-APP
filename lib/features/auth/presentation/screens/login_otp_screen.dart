import 'dart:async';
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

/// Next-Generation Authentication Screen supporting:
/// - Bangladeshi Mobile OTP (with countdown timer & 6-digit PIN boxes)
/// - Mobile & Password Login
/// - Dynamic Role Switching (Tenant vs Landlord) with tailored UI themes
/// - Seamless Clean Architecture BLoC Integration
class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<TextEditingController> _otpDigitControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  UserRole _selectedRole = UserRole.tenant;
  bool _isOtpSent = false;
  bool _usePasswordMode = false;
  bool _obscurePassword = true;
  String _sentPhoneNumber = '';

  // Resend Countdown Timer
  Timer? _countdownTimer;
  int _secondsRemaining = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    for (final c in _otpDigitControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _canResendOtp = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResendOtp = true;
        });
      }
    });
  }

  void _onRoleChanged(UserRole role) {
    if (_selectedRole == role) return;
    setState(() {
      _selectedRole = role;
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
    // Bangladeshi mobile numbers are 11 digits starting with 013..019
    if (clean.length == 11 && clean.startsWith('01')) {
      return true;
    }
    if (clean.length == 13 && clean.startsWith('8801')) {
      return true;
    }
    return false;
  }

  void _onSendOtp() {
    final rawPhone = _phoneController.text.trim();
    if (!_isValidBdPhone(rawPhone)) {
      _showToast('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: 01712345678)', isError: true);
      return;
    }
    final formattedPhone = _formatToBdPhone(rawPhone);
    _sentPhoneNumber = formattedPhone;

    // Directly set OTP 123456 without needing to dispatch an SMS
    setState(() {
      _isOtpSent = true;
      const defaultOtp = ['1', '2', '3', '4', '5', '6'];
      for (int i = 0; i < _otpDigitControllers.length; i++) {
        _otpDigitControllers[i].text = defaultOtp[i];
      }
    });
    _startCountdownTimer();
    _showToast('ওটিপি কোড: 123456 (স্বয়ংক্রিয়ভাবে প্রস্তুত)');

    // Directly submit verification with 123456
    context.read<AuthBloc>().add(
          VerifyOtpRequestedEvent(
            phoneNumber: formattedPhone,
            otpCode: '123456',
            role: _selectedRole,
          ),
        );
  }

  void _onVerifyOtp() {
    var code = _otpDigitControllers.map((c) => c.text).join().trim();
    if (code.length < 6) {
      code = '123456';
      const defaultOtp = ['1', '2', '3', '4', '5', '6'];
      for (int i = 0; i < _otpDigitControllers.length; i++) {
        _otpDigitControllers[i].text = defaultOtp[i];
      }
    }

    context.read<AuthBloc>().add(
          VerifyOtpRequestedEvent(
            phoneNumber: _sentPhoneNumber.isNotEmpty ? _sentPhoneNumber : _formatToBdPhone(_phoneController.text.trim()),
            otpCode: code,
            role: _selectedRole,
          ),
        );
  }

  void _onPasswordLogin() {
    final rawPhone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (!_isValidBdPhone(rawPhone)) {
      _showToast('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন', isError: true);
      return;
    }
    if (password.length < 6) {
      _showToast('পাসওয়ার্ড কমপক্ষে ৬ ডিজিট হতে হবে', isError: true);
      return;
    }

    final formattedPhone = _formatToBdPhone(rawPhone);
    context.read<AuthBloc>().add(
          LoginWithPasswordRequestedEvent(
            phoneNumber: formattedPhone,
            password: password,
            role: _selectedRole,
          ),
        );
  }

  void _quickDemoLogin(UserRole role) {
    setState(() {
      _selectedRole = role;
    });

    final phone = role == UserRole.landlord ? '+8801812345678' : '+8801712345678';
    context.read<AuthBloc>().add(
          VerifyOtpRequestedEvent(
            phoneNumber: phone,
            otpCode: '123456',
            role: role,
          ),
        );
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => context.goNamed(RouteNames.home),
              style: TextButton.styleFrom(
                backgroundColor: primarySoftColor.withAlpha(120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: Icon(Icons.explore_outlined, size: 16, color: primaryColor),
              label: Text(
                'Explore Flats',
                style: AppTypography.labelMedium.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            setState(() {
              _isOtpSent = true;
              _sentPhoneNumber = state.phoneNumber;
              for (final c in _otpDigitControllers) {
                c.clear();
              }
            });
            _startCountdownTimer();
            _showToast('আপনার মোবাইলে ৬-ডিজিট ওটিপি পাঠানো হয়েছে (ডেমো: 123456)');
          } else if (state is Authenticated) {
            _countdownTimer?.cancel();
            _showToast(
              state.user.isLandlord
                  ? 'স্বাগতম বাড়িওয়ালা ${state.user.fullName}! প্রবেশ করছেন ল্যান্ডলর্ড ভল্টে...'
                  : 'স্বাগতম ভাড়াটিয়া ${state.user.fullName}! বাসা খুঁজুন সরাসরি মালিকদের সাথে...',
            );
            if (state.user.isLandlord) {
              context.goNamed(RouteNames.propertyVault);
            } else {
              context.goNamed(RouteNames.home);
            }
          } else if (state is AuthError) {
            _showToast(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header & Role Glow
                  _buildBrandHero(primaryColor, isLandlord),
                  const SizedBox(height: 24),

                  // Role Segmented Switcher (Tenant vs Landlord)
                  _buildRoleSelector(isLandlord),
                  const SizedBox(height: 20),

                  // Auth Mode Tabs (OTP vs Password)
                  if (!_isOtpSent) _buildAuthModeTabs(primaryColor),
                  const SizedBox(height: 24),

                  // Main Interactive Form Area
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isOtpSent
                        ? _buildOtpVerificationSection(
                            primaryColor,
                            primarySoftColor,
                            isLoading,
                          )
                        : _usePasswordMode
                            ? _buildPasswordLoginSection(primaryColor, isLoading)
                            : _buildPhoneOtpRequestSection(primaryColor, isLoading),
                  ),

                  const SizedBox(height: 28),

                  // Create Account Link
                  _buildRegisterPrompt(primaryColor),

                  const SizedBox(height: 24),

                  // Quick Demo Pills (Discreet and Professional for testing)
                  _buildDemoQuickAccessBar(primaryColor),

                  const SizedBox(height: 24),

                  // Security & Trust Badges
                  _buildTrustBadges(isLandlord),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Brand Hero Header with dynamic role identity
  Widget _buildBrandHero(Color primaryColor, bool isLandlord) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withAlpha(200),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha(70),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isLandlord ? Icons.apartment_rounded : Icons.home_work_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rent',
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.lightTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'BD',
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isLandlord
              ? 'বাড়িওয়ালা ড্যাশবোর্ড ও ডিজিটাল ভল্ট'
              : 'ঢাকা ও সারা বাংলাদেশের ভেরিফাইড ফ্ল্যাট রেন্টাল',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Segmented Role Selector (Tenant vs Landlord)
  Widget _buildRoleSelector(bool isLandlord) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tenant Option
          Expanded(
            child: GestureDetector(
              onTap: () => _onRoleChanged(UserRole.tenant),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isLandlord ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isLandlord
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_pin_circle_rounded,
                      size: 19,
                      color: !isLandlord ? Colors.white : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ভাড়াটিয়া (Tenant)',
                      style: AppTypography.titleSmall.copyWith(
                        color: !isLandlord ? Colors.white : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Landlord Option
          Expanded(
            child: GestureDetector(
              onTap: () => _onRoleChanged(UserRole.landlord),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLandlord ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLandlord
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 19,
                      color: isLandlord ? Colors.white : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'বাড়িওয়ালা (Owner)',
                      style: AppTypography.titleSmall.copyWith(
                        color: isLandlord ? Colors.white : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Auth Mode Tabs (SMS OTP vs Password)
  Widget _buildAuthModeTabs(Color primaryColor) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.lightDivider,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePasswordMode = false),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: !_usePasswordMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_usePasswordMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sms_outlined,
                        size: 16,
                        color: !_usePasswordMode
                            ? primaryColor
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mobile OTP',
                        style: AppTypography.labelLarge.copyWith(
                          color: !_usePasswordMode
                              ? primaryColor
                              : AppColors.lightTextSecondary,
                          fontWeight: !_usePasswordMode ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _usePasswordMode = true),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _usePasswordMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _usePasswordMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: _usePasswordMode
                            ? primaryColor
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Password Login',
                        style: AppTypography.labelLarge.copyWith(
                          color: _usePasswordMode
                              ? primaryColor
                              : AppColors.lightTextSecondary,
                          fontWeight: _usePasswordMode ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Phone OTP Request Section
  Widget _buildPhoneOtpRequestSection(Color primaryColor, bool isLoading) {
    return Column(
      key: const ValueKey('phone_otp_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'মোবাইল নম্বর লিখুন',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ওটিপি কোড: 123456 (এসএমএস পাঠানোর প্রয়োজন নেই, সরাসরি লগইন হবে)',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Phone Input with BD Flag
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
                    const Text('🇧🇩', style: TextStyle(fontSize: 20)),
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
                child: TextField(
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
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Send OTP Button
        BariButton(
          label: 'Login with OTP: 123456 (লগইন করুন)',
          isLoading: isLoading,
          variant: _selectedRole == UserRole.landlord
              ? BariButtonVariant.secondary
              : BariButtonVariant.primary,
          leadingIcon: const Icon(Icons.lock_open_rounded, size: 18, color: Colors.white),
          onPressed: _onSendOtp,
        ),
      ],
    );
  }

  /// 6-Digit OTP Verification Section
  Widget _buildOtpVerificationSection(
    Color primaryColor,
    Color primarySoftColor,
    bool isLoading,
  ) {
    return Column(
      key: const ValueKey('otp_verify_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Info Box with Change Number action
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primarySoftColor.withAlpha(90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primaryColor.withAlpha(50)),
          ),
          child: Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification code sent to:',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      _sentPhoneNumber,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _countdownTimer?.cancel();
                  setState(() => _isOtpSent = false);
                },
                child: Text(
                  'Change',
                  style: AppTypography.labelLarge.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 6-Digit Pin Fields
        Text(
          'Enter 6-Digit OTP Code (ডিফল্ট: 123456)',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: _otpDigitControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2.0),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (_otpDigitControllers.every((c) => c.text.isNotEmpty)) {
                    _onVerifyOtp();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 18),

        // Resend Timer & Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _secondsRemaining > 0
                      ? AppColors.lightTextSecondary
                      : AppColors.lightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _secondsRemaining > 0
                      ? 'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                      : 'Did not receive code?',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _canResendOtp ? _onSendOtp : null,
              child: Text(
                'Resend Code (পুনরায় পাঠান)',
                style: AppTypography.labelMedium.copyWith(
                  color: _canResendOtp ? primaryColor : AppColors.lightTextMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Verify and Continue CTA
        BariButton(
          label: 'Verify & Sign In (যাচাই করুন)',
          isLoading: isLoading,
          variant: _selectedRole == UserRole.landlord
              ? BariButtonVariant.secondary
              : BariButtonVariant.primary,
          leadingIcon: const Icon(Icons.check_circle_outline_rounded,
              size: 20, color: Colors.white),
          onPressed: _onVerifyOtp,
        ),
      ],
    );
  }

  /// Password Login Section
  Widget _buildPasswordLoginSection(Color primaryColor, bool isLoading) {
    return Column(
      key: const ValueKey('password_login_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone Input
        BariTextField(
          controller: _phoneController,
          label: 'Mobile Number (বাংলাদেশ মোবাইল নম্বর)',
          hintText: '017XXXXXXXX',
          keyboardType: TextInputType.phone,
          prefixIcon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Text(
              '+880',
              style: AppTypography.titleMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Input
        BariTextField(
          controller: _passwordController,
          label: 'Password (পাসওয়ার্ড)',
          hintText: '••••••••',
          obscureText: _obscurePassword,
          prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.lightTextMuted,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 12),

        // Forgot Password link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              setState(() => _usePasswordMode = false);
              _showToast('পাসওয়ার্ড ভুলে গেলে ওটিপি (OTP) দিয়ে সরাসরি লগইন করুন');
            },
            child: Text(
              'Forgot Password? Use OTP Login',
              style: AppTypography.bodySmall.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Sign In Button
        BariButton(
          label: _selectedRole == UserRole.landlord
              ? 'Sign in as Landlord (লগইন করুন)'
              : 'Sign in as Tenant (লগইন করুন)',
          isLoading: isLoading,
          variant: _selectedRole == UserRole.landlord
              ? BariButtonVariant.secondary
              : BariButtonVariant.primary,
          leadingIcon: const Icon(Icons.login_rounded, size: 20, color: Colors.white),
          onPressed: _onPasswordLogin,
        ),
      ],
    );
  }

  /// Create Account Navigation Link
  Widget _buildRegisterPrompt(Color primaryColor) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to RentBD? ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.lightTextSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.register),
            child: Text(
              'Create Account (রেজিস্ট্রেশন)',
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

  /// Discreet & Professional Demo Login Bar (For Testing)
  Widget _buildDemoQuickAccessBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 0.9),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            'Demo:',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _quickDemoLogin(UserRole.tenant),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft.withAlpha(160),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withAlpha(60)),
                      ),
                      child: Center(
                        child: Text(
                          'Tenant Tanvir',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _quickDemoLogin(UserRole.landlord),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondarySoft.withAlpha(160),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondary.withAlpha(60)),
                      ),
                      child: Center(
                        child: Text(
                          'Landlord Rafiq',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Security & Trust Badges
  Widget _buildTrustBadges(bool isLandlord) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrustItem(
                Icons.verified_user_rounded,
                'DMP Verified',
                'Dhaka Police CIMS Compliant',
              ),
              _buildTrustItem(
                Icons.lock_rounded,
                '256-Bit SSL',
                'Encrypted & Secure',
              ),
              _buildTrustItem(
                Icons.handshake_rounded,
                '0% Broker Fee',
                'Direct Tenant-Owner',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9,
            color: AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
