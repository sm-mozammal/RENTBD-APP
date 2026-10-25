import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_formatter.dart';
import '../../../../core/network/token_manager.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Clean Architecture BLoC for Authentication and User Profile management.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.switchRoleUseCase,
    required this.registerUseCase,
    required this.changePasswordUseCase,
    required this.submitKycUseCase,
    required this.loginWithPasswordUseCase,
    this.signOutUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpRequestedEvent>(_onSendOtpRequested);
    on<VerifyOtpRequestedEvent>(_onVerifyOtpRequested);
    on<LoginWithPasswordRequestedEvent>(_onLoginWithPasswordRequested);
    on<RegisterRequestedEvent>(_onRegisterRequested);
    on<ChangePasswordRequestedEvent>(_onChangePasswordRequested);
    on<SubmitKycRequestedEvent>(_onSubmitKycRequested);
    on<UpdateProfileRequestedEvent>(_onUpdateProfileRequested);
    on<SwitchRoleRequestedEvent>(_onSwitchRoleRequested);
    on<SignOutRequestedEvent>(_onSignOutRequested);
  }

  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final SwitchRoleUseCase switchRoleUseCase;
  final RegisterUseCase registerUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final SubmitKycUseCase submitKycUseCase;
  final LoginWithPasswordUseCase loginWithPasswordUseCase;
  final SignOutUseCase? signOutUseCase;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) {
      emit(const AuthLoading(message: 'Checking authentication...'));
    }
    try {
      final user = await getProfileUseCase();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        await TokenManager.clear();
        emit(const Unauthenticated());
      }
    } catch (_) {
      // Gracefully attempt restoring user from secure storage session cache if offline
      if (TokenManager.cachedUserProfileJson != null) {
        try {
          final cached = jsonDecode(TokenManager.cachedUserProfileJson!) as Map<String, dynamic>;
          final user = UserProfileModel.fromJson(cached).toEntity();
          emit(Authenticated(user: user));
          return;
        } catch (_) {}
      }
      if (state is! Authenticated) {
        emit(const Unauthenticated());
      }
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Sending OTP via SMS...'));
    try {
      final success = await sendOtpUseCase(event.phoneNumber);
      if (success) {
        emit(OtpSentState(phoneNumber: event.phoneNumber));
      } else {
        emit(const AuthError(message: 'ওটিপি পাঠাতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন। (Failed to send OTP)'));
      }
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying OTP code...'));
    try {
      final user = await verifyOtpUseCase(
        event.phoneNumber,
        event.otpCode,
        role: event.role,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onLoginWithPasswordRequested(
    LoginWithPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in with password...'));
    try {
      final user = await loginWithPasswordUseCase(
        phoneNumber: event.phoneNumber,
        password: event.password,
        role: event.role,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating your account...'));
    try {
      final user = await registerUseCase(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state is Authenticated ? (state as Authenticated).user : null;
    emit(const AuthLoading(message: 'Updating password...'));
    try {
      await changePasswordUseCase(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      if (currentUser != null) {
        emit(PasswordChangeSuccessState(user: currentUser));
        emit(Authenticated(user: currentUser));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onSubmitKycRequested(
    SubmitKycRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Submitting KYC for verification...'));
    try {
      final updated = await submitKycUseCase(
        nidNumber: event.nidNumber,
        presentAddress: event.presentAddress,
        emergencyContact: event.emergencyContact,
        nidFrontUrl: event.nidFrontUrl,
        nidBackUrl: event.nidBackUrl,
        selfieUrl: event.selfieUrl,
      );
      emit(Authenticated(user: updated));
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Updating profile...'));
    try {
      final updated = await updateProfileUseCase(event.profile);
      emit(Authenticated(user: updated));
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onSwitchRoleRequested(
    SwitchRoleRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final updated = await switchRoleUseCase(event.newRole);
      emit(Authenticated(user: updated));
    } catch (e) {
      emit(AuthError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (signOutUseCase != null) {
        await signOutUseCase!();
      } else {
        await TokenManager.clear();
      }
    } catch (_) {
      await TokenManager.clear();
    }
    emit(const Unauthenticated());
  }
}
