import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:rentbd_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rentbd_app/features/auth/domain/entities/user_profile.dart';
import 'package:rentbd_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('AuthBloc Unit & Integration Flow', () {
    late AuthMockDataSource mockDataSource;
    late AuthRepositoryImpl authRepository;
    late SendOtpUseCase sendOtpUseCase;
    late VerifyOtpUseCase verifyOtpUseCase;
    late GetProfileUseCase getProfileUseCase;
    late UpdateProfileUseCase updateProfileUseCase;
    late SwitchRoleUseCase switchRoleUseCase;
    late RegisterUseCase registerUseCase;
    late ChangePasswordUseCase changePasswordUseCase;
    late SubmitKycUseCase submitKycUseCase;
    late LoginWithPasswordUseCase loginWithPasswordUseCase;

    setUp(() {
      AppEnvironment.mockDelay = Duration.zero;
      mockDataSource = AuthMockDataSource();
      authRepository = AuthRepositoryImpl(
        mockDataSource: mockDataSource,
        remoteDataSource: mockDataSource,
      );
      sendOtpUseCase = SendOtpUseCase(authRepository);
      verifyOtpUseCase = VerifyOtpUseCase(authRepository);
      getProfileUseCase = GetProfileUseCase(authRepository);
      updateProfileUseCase = UpdateProfileUseCase(authRepository);
      switchRoleUseCase = SwitchRoleUseCase(authRepository);
      registerUseCase = RegisterUseCase(authRepository);
      changePasswordUseCase = ChangePasswordUseCase(authRepository);
      submitKycUseCase = SubmitKycUseCase(authRepository);
      loginWithPasswordUseCase = LoginWithPasswordUseCase(authRepository);
    });

    AuthBloc buildBloc() {
      return AuthBloc(
        sendOtpUseCase: sendOtpUseCase,
        verifyOtpUseCase: verifyOtpUseCase,
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        switchRoleUseCase: switchRoleUseCase,
        registerUseCase: registerUseCase,
        changePasswordUseCase: changePasswordUseCase,
        submitKycUseCase: submitKycUseCase,
        loginWithPasswordUseCase: loginWithPasswordUseCase,
      );
    }

    test('initial state is AuthInitial', () {
      expect(buildBloc().state, equals(const AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when CheckAuthStatusEvent is added and user exists',
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>().having((s) => s.user.phoneNumber, 'phoneNumber', '+8801712345678'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpSentState] when SendOtpRequestedEvent is added',
      build: buildBloc,
      act: (bloc) => bloc.add(const SendOtpRequestedEvent(phoneNumber: '01712345678')),
      expect: () => [
        isA<AuthLoading>(),
        isA<OtpSentState>().having((s) => s.phoneNumber, 'phoneNumber', '01712345678'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when VerifyOtpRequestedEvent is added with valid OTP',
      build: buildBloc,
      act: (bloc) => bloc.add(const VerifyOtpRequestedEvent(
        phoneNumber: '01712345678',
        otpCode: '123456',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>().having((s) => s.user.fullName, 'fullName', 'Tanvir Ahmed (Tenant)'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when RegisterRequestedEvent is added',
      build: buildBloc,
      act: (bloc) => bloc.add(const RegisterRequestedEvent(
        fullName: 'Habib Rahman',
        phoneNumber: '+8801811223344',
        email: 'habib@gmail.com',
        password: 'password123',
        role: UserRole.tenant,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((s) => s.user.fullName, 'fullName', 'Habib Rahman')
            .having((s) => s.user.role, 'role', UserRole.tenant)
            .having((s) => s.user.isKycCompleted, 'isKycCompleted', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when SubmitKycRequestedEvent is added for tenant',
      build: buildBloc,
      act: (bloc) => bloc.add(const SubmitKycRequestedEvent(
        nidNumber: '19951234567890',
        presentAddress: 'Dhanmondi, Dhaka',
        emergencyContact: 'Karim - 01700000000',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((s) => s.user.isNidVerified, 'isNidVerified', true)
            .having((s) => s.user.isKycCompleted, 'isKycCompleted', true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when SignOutRequestedEvent is added',
      build: buildBloc,
      act: (bloc) => bloc.add(const SignOutRequestedEvent()),
      expect: () => [
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'switches user role from tenant to landlord',
      build: buildBloc,
      act: (bloc) => bloc.add(const SwitchRoleRequestedEvent(newRole: UserRole.landlord)),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<Authenticated>().having((s) => s.user.role, 'role', UserRole.landlord),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authenticates as Landlord when VerifyOtpRequestedEvent is called with UserRole.landlord',
      build: buildBloc,
      act: (bloc) => bloc.add(const VerifyOtpRequestedEvent(
        phoneNumber: '+8801812345678',
        otpCode: '123456',
        role: UserRole.landlord,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((s) => s.user.role, 'role', UserRole.landlord)
            .having((s) => s.user.isLandlord, 'isLandlord', true)
            .having((s) => s.user.fullName, 'fullName', contains('Rafiq')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authenticates as Landlord when LoginWithPasswordRequestedEvent is called',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoginWithPasswordRequestedEvent(
        phoneNumber: '+8801812345678',
        password: 'SecurePassword123',
        role: UserRole.landlord,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((s) => s.user.role, 'role', UserRole.landlord)
            .having((s) => s.user.isLandlord, 'isLandlord', true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authenticates as Tenant when LoginWithPasswordRequestedEvent is called',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoginWithPasswordRequestedEvent(
        phoneNumber: '+8801712345678',
        password: 'SecurePassword123',
        role: UserRole.tenant,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((s) => s.user.role, 'role', UserRole.tenant)
            .having((s) => s.user.isTenant, 'isTenant', true),
      ],
    );
  });
}
