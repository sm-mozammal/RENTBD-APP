import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/communication_ledger/data/datasources/chat_mock_datasource.dart';
import '../../features/communication_ledger/data/datasources/chat_remote_datasource.dart';
import '../../features/communication_ledger/data/datasources/ledger_mock_datasource.dart';
import '../../features/communication_ledger/data/datasources/ledger_remote_datasource.dart';
import '../../features/communication_ledger/data/repositories/chat_repository_impl.dart';
import '../../features/communication_ledger/data/repositories/ledger_repository_impl.dart';
import '../../features/communication_ledger/domain/repositories/chat_repository.dart';
import '../../features/communication_ledger/domain/repositories/ledger_repository.dart';
import '../../features/communication_ledger/domain/usecases/chat_usecases.dart';
import '../../features/communication_ledger/domain/usecases/ledger_usecases.dart';
import '../../features/location/data/datasources/insight_mock_datasource.dart';
import '../../features/location/data/datasources/insight_remote_datasource.dart';
import '../../features/location/data/repositories/insight_repository_impl.dart';
import '../../features/location/domain/repositories/insight_repository.dart';
import '../../features/location/domain/usecases/insight_usecases.dart';
import '../../features/property/data/datasources/property_mock_datasource.dart';
import '../../features/property/data/datasources/property_remote_datasource.dart';
import '../../features/property/data/repositories/property_repository_impl.dart';
import '../../features/property/domain/repositories/property_repository.dart';
import '../../features/property/domain/usecases/property_usecases.dart';
import '../../features/property/presentation/bloc/property_bloc.dart';
import '../../features/visit/data/datasources/visit_mock_datasource.dart';
import '../../features/visit/data/datasources/visit_remote_datasource.dart';
import '../../features/visit/data/repositories/visit_repository_impl.dart';
import '../../features/visit/domain/repositories/visit_repository.dart';
import '../../features/visit/domain/usecases/visit_usecases.dart';
import '../network/dio_client.dart';

/// Global GetIt instance for dependency injection across RentBD.
final GetIt sl = GetIt.instance;

/// Alias for developers preferring the `getIt` identifier.
final GetIt getIt = sl;

/// Centralized Clean Architecture Dependency Injection Setup using GetIt.
/// Registers all DataSources, Repositories, Domain UseCases, and BLoC Factories.
class ServiceLocator {
  ServiceLocator._();

  static bool _initialized = false;

  /// Initializes all layers in Clean Architecture order:
  /// 1. Network & Core (DioClient)
  /// 2. Data Sources (Mock & Remote)
  /// 3. Repositories (routed via Zero-Rework Contract)
  /// 4. Domain Use Cases
  /// 5. Presentation BLoCs (Factories)
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // -------------------------------------------------------------
    // 1. Core & Network Client
    // -------------------------------------------------------------
    sl.registerLazySingleton<DioClient>(() => DioClient());

    // -------------------------------------------------------------
    // 2. Data Sources & Repositories (Layered by Feature)
    // -------------------------------------------------------------
    // Auth Layer
    sl.registerLazySingleton<AuthMockDataSource>(() => AuthMockDataSource());
    sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl<DioClient>()));
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        mockDataSource: sl<AuthMockDataSource>(),
        remoteDataSource: sl<AuthRemoteDataSource>(),
      ),
    );

    // Property Layer
    sl.registerLazySingleton<PropertyMockDataSource>(() => PropertyMockDataSource());
    sl.registerLazySingleton<PropertyRemoteDataSource>(() => PropertyRemoteDataSource(sl<DioClient>()));
    sl.registerLazySingleton<PropertyRepository>(
      () => PropertyRepositoryImpl(
        mockDataSource: sl<PropertyMockDataSource>(),
        remoteDataSource: sl<PropertyRemoteDataSource>(),
      ),
    );

    // Visit Layer
    sl.registerLazySingleton<VisitMockDataSource>(() => VisitMockDataSource());
    sl.registerLazySingleton<VisitRemoteDataSource>(() => VisitRemoteDataSource(sl<DioClient>()));
    sl.registerLazySingleton<VisitRepository>(
      () => VisitRepositoryImpl(
        mockDataSource: sl<VisitMockDataSource>(),
        remoteDataSource: sl<VisitRemoteDataSource>(),
      ),
    );

    // Insight Layer
    sl.registerLazySingleton<InsightMockDataSource>(() => InsightMockDataSource());
    sl.registerLazySingleton<InsightRemoteDataSource>(() => InsightRemoteDataSource(sl<DioClient>()));
    sl.registerLazySingleton<InsightRepository>(
      () => InsightRepositoryImpl(
        mockDataSource: sl<InsightMockDataSource>(),
        remoteDataSource: sl<InsightRemoteDataSource>(),
      ),
    );

    // Ledger Layer
    sl.registerLazySingleton<LedgerMockDataSource>(() => LedgerMockDataSource());
    sl.registerLazySingleton<LedgerRemoteDataSource>(() => LedgerRemoteDataSource(sl<DioClient>()));
    sl.registerLazySingleton<LedgerRepository>(
      () => LedgerRepositoryImpl(
        mockDataSource: sl<LedgerMockDataSource>(),
        remoteDataSource: sl<LedgerRemoteDataSource>(),
      ),
    );

    // Chat Layer
    sl.registerLazySingleton<ChatMockDataSource>(() => ChatMockDataSource());
    sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSource(sl<DioClient>()));
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        mockDataSource: sl<ChatMockDataSource>(),
        remoteDataSource: sl<ChatRemoteDataSource>(),
      ),
    );

    // -------------------------------------------------------------
    // 3. Domain Use Cases
    // -------------------------------------------------------------
    // Auth UseCases
    sl.registerLazySingleton(() => SendOtpUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => GetProfileUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SwitchRoleUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => ChangePasswordUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SubmitKycUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => LoginWithPasswordUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));

    // Property UseCases
    sl.registerLazySingleton(() => GetPropertiesUseCase(sl<PropertyRepository>()));
    sl.registerLazySingleton(() => GetPropertyByIdUseCase(sl<PropertyRepository>()));
    sl.registerLazySingleton(() => ToggleSavePropertyUseCase(sl<PropertyRepository>()));
    sl.registerLazySingleton(() => GetSavedPropertiesUseCase(sl<PropertyRepository>()));
    sl.registerLazySingleton(() => NaturalLanguageSearchUseCase(sl<PropertyRepository>()));
    sl.registerLazySingleton(() => CreatePropertyUseCase(sl<PropertyRepository>()));
    sl.registerLazySingleton(() => ToggleVaultUseCase(sl<PropertyRepository>()));

    // Visit UseCases
    sl.registerLazySingleton(() => BookVisitUseCase(sl<VisitRepository>()));
    sl.registerLazySingleton(() => GetMyVisitsUseCase(sl<VisitRepository>()));
    sl.registerLazySingleton(() => UpdateVisitStatusUseCase(sl<VisitRepository>()));
    sl.registerLazySingleton(() => SubmitInquiryUseCase(sl<VisitRepository>()));
    sl.registerLazySingleton(() => GetScreeningInboxUseCase(sl<VisitRepository>()));

    // Insight UseCases
    sl.registerLazySingleton(() => GetAreaInsightUseCase(sl<InsightRepository>()));
    sl.registerLazySingleton(() => SubmitAreaInsightUseCase(sl<InsightRepository>()));

    // Ledger UseCases
    sl.registerLazySingleton(() => CreateTenancyUseCase(sl<LedgerRepository>()));
    sl.registerLazySingleton(() => GetBillsUseCase(sl<LedgerRepository>()));
    sl.registerLazySingleton(() => IssueBillUseCase(sl<LedgerRepository>()));
    sl.registerLazySingleton(() => MarkBillPaidUseCase(sl<LedgerRepository>()));
    sl.registerLazySingleton(() => GetReceiptUseCase(sl<LedgerRepository>()));

    // Chat UseCases
    sl.registerLazySingleton(() => GetChatRoomsUseCase(sl<ChatRepository>()));
    sl.registerLazySingleton(() => CreateChatRoomUseCase(sl<ChatRepository>()));
    sl.registerLazySingleton(() => GetChatMessagesUseCase(sl<ChatRepository>()));
    sl.registerLazySingleton(() => SendChatMessageUseCase(sl<ChatRepository>()));
    sl.registerLazySingleton(() => GetAgoraCallTokenUseCase(sl<ChatRepository>()));

    // -------------------------------------------------------------
    // 4. Presentation BLoCs (Factories for fresh instances)
    // -------------------------------------------------------------
    sl.registerFactory(
      () => AuthBloc(
        sendOtpUseCase: sl<SendOtpUseCase>(),
        verifyOtpUseCase: sl<VerifyOtpUseCase>(),
        getProfileUseCase: sl<GetProfileUseCase>(),
        updateProfileUseCase: sl<UpdateProfileUseCase>(),
        switchRoleUseCase: sl<SwitchRoleUseCase>(),
        registerUseCase: sl<RegisterUseCase>(),
        changePasswordUseCase: sl<ChangePasswordUseCase>(),
        submitKycUseCase: sl<SubmitKycUseCase>(),
        loginWithPasswordUseCase: sl<LoginWithPasswordUseCase>(),
        signOutUseCase: sl<SignOutUseCase>(),
      ),
    );

    sl.registerFactory(
      () => PropertyBloc(
        getPropertiesUseCase: sl<GetPropertiesUseCase>(),
        getPropertyByIdUseCase: sl<GetPropertyByIdUseCase>(),
        toggleSavePropertyUseCase: sl<ToggleSavePropertyUseCase>(),
        getSavedPropertiesUseCase: sl<GetSavedPropertiesUseCase>(),
        naturalLanguageSearchUseCase: sl<NaturalLanguageSearchUseCase>(),
      ),
    );
  }

  // -------------------------------------------------------------
  // Backward-compatible Static Accessors delegating to GetIt
  // -------------------------------------------------------------
  static DioClient get dioClient => sl<DioClient>();

  static AuthRepository get authRepository => sl<AuthRepository>();
  static PropertyRepository get propertyRepository => sl<PropertyRepository>();
  static VisitRepository get visitRepository => sl<VisitRepository>();
  static InsightRepository get insightRepository => sl<InsightRepository>();
  static LedgerRepository get ledgerRepository => sl<LedgerRepository>();
  static ChatRepository get chatRepository => sl<ChatRepository>();

  static SendOtpUseCase get sendOtpUseCase => sl<SendOtpUseCase>();
  static VerifyOtpUseCase get verifyOtpUseCase => sl<VerifyOtpUseCase>();
  static GetProfileUseCase get getProfileUseCase => sl<GetProfileUseCase>();
  static UpdateProfileUseCase get updateProfileUseCase => sl<UpdateProfileUseCase>();
  static SwitchRoleUseCase get switchRoleUseCase => sl<SwitchRoleUseCase>();
  static RegisterUseCase get registerUseCase => sl<RegisterUseCase>();
  static ChangePasswordUseCase get changePasswordUseCase => sl<ChangePasswordUseCase>();
  static SubmitKycUseCase get submitKycUseCase => sl<SubmitKycUseCase>();
  static LoginWithPasswordUseCase get loginWithPasswordUseCase => sl<LoginWithPasswordUseCase>();

  static GetPropertiesUseCase get getPropertiesUseCase => sl<GetPropertiesUseCase>();
  static GetPropertyByIdUseCase get getPropertyByIdUseCase => sl<GetPropertyByIdUseCase>();
  static ToggleSavePropertyUseCase get toggleSavePropertyUseCase => sl<ToggleSavePropertyUseCase>();
  static GetSavedPropertiesUseCase get getSavedPropertiesUseCase => sl<GetSavedPropertiesUseCase>();
  static NaturalLanguageSearchUseCase get naturalLanguageSearchUseCase => sl<NaturalLanguageSearchUseCase>();

  static BookVisitUseCase get bookVisitUseCase => sl<BookVisitUseCase>();
  static GetMyVisitsUseCase get getMyVisitsUseCase => sl<GetMyVisitsUseCase>();
  static UpdateVisitStatusUseCase get updateVisitStatusUseCase => sl<UpdateVisitStatusUseCase>();
  static SubmitInquiryUseCase get submitInquiryUseCase => sl<SubmitInquiryUseCase>();
  static GetScreeningInboxUseCase get getScreeningInboxUseCase => sl<GetScreeningInboxUseCase>();

  static GetAreaInsightUseCase get getAreaInsightUseCase => sl<GetAreaInsightUseCase>();
  static SubmitAreaInsightUseCase get submitAreaInsightUseCase => sl<SubmitAreaInsightUseCase>();

  static CreateTenancyUseCase get createTenancyUseCase => sl<CreateTenancyUseCase>();
  static GetBillsUseCase get getBillsUseCase => sl<GetBillsUseCase>();
  static IssueBillUseCase get issueBillUseCase => sl<IssueBillUseCase>();
  static MarkBillPaidUseCase get markBillPaidUseCase => sl<MarkBillPaidUseCase>();
  static GetReceiptUseCase get getReceiptUseCase => sl<GetReceiptUseCase>();

  static GetChatRoomsUseCase get getChatRoomsUseCase => sl<GetChatRoomsUseCase>();
  static CreateChatRoomUseCase get createChatRoomUseCase => sl<CreateChatRoomUseCase>();
  static GetChatMessagesUseCase get getChatMessagesUseCase => sl<GetChatMessagesUseCase>();
  static SendChatMessageUseCase get sendChatMessageUseCase => sl<SendChatMessageUseCase>();
  static GetAgoraCallTokenUseCase get getAgoraCallTokenUseCase => sl<GetAgoraCallTokenUseCase>();

  /// Reset locator registrations (useful in tests)
  static Future<void> reset() async {
    await sl.reset();
    _initialized = false;
  }
}
