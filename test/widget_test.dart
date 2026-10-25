import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentbd_app/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:rentbd_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rentbd_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rentbd_app/features/property/data/datasources/property_mock_datasource.dart';
import 'package:rentbd_app/features/property/data/repositories/property_repository_impl.dart';
import 'package:rentbd_app/features/property/domain/usecases/property_usecases.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_event.dart';
import 'package:rentbd_app/main.dart';

void main() {
  testWidgets('RentBD App initial launch smoke test', (WidgetTester tester) async {
    final authMockDataSource = AuthMockDataSource();
    final authRepository = AuthRepositoryImpl(
      mockDataSource: authMockDataSource,
      remoteDataSource: authMockDataSource,
    );
    final authBloc = AuthBloc(
      sendOtpUseCase: SendOtpUseCase(authRepository),
      verifyOtpUseCase: VerifyOtpUseCase(authRepository),
      getProfileUseCase: GetProfileUseCase(authRepository),
      updateProfileUseCase: UpdateProfileUseCase(authRepository),
      switchRoleUseCase: SwitchRoleUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      changePasswordUseCase: ChangePasswordUseCase(authRepository),
      submitKycUseCase: SubmitKycUseCase(authRepository),
      loginWithPasswordUseCase: LoginWithPasswordUseCase(authRepository),
    )..add(const CheckAuthStatusEvent());

    final propertyMockDataSource = PropertyMockDataSource();
    final propertyRepository = PropertyRepositoryImpl(
      mockDataSource: propertyMockDataSource,
      remoteDataSource: propertyMockDataSource,
    );
    final propertyBloc = PropertyBloc(
      getPropertiesUseCase: GetPropertiesUseCase(propertyRepository),
      getPropertyByIdUseCase: GetPropertyByIdUseCase(propertyRepository),
      toggleSavePropertyUseCase: ToggleSavePropertyUseCase(propertyRepository),
      getSavedPropertiesUseCase: GetSavedPropertiesUseCase(propertyRepository),
      naturalLanguageSearchUseCase: NaturalLanguageSearchUseCase(propertyRepository),
    )..add(const FetchPropertiesEvent());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<PropertyBloc>.value(value: propertyBloc),
        ],
        child: const RentBdApp(),
      ),
    );

    // Set mock delay to zero for instant testing
    AppEnvironment.mockDelay = Duration.zero;

    // Initial frame render
    await tester.pumpAndSettle();

    // Verify app renders with Home area selector and Explore navigation tab
    expect(find.text('All Dhaka'), findsWidgets);
    expect(find.text('Explore'), findsWidgets);
  });
}
