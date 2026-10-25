# RentBD — Clean Architecture & API Implementation Rules (GEMINI.md)

This document establishes the mandatory architectural rules, engineering standards, and API implementation invariants for the **RentBD** Flutter mobile application. Every developer and AI assistant working on this codebase **MUST strictly adhere to these rules without exception**.

---

## 🏛️ 1. Clean Architecture Layer Hierarchy

The application follows strict **Uncle Bob Clean Architecture** divided into three decoupled layers: **Domain**, **Data**, and **Presentation**.

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  (UI Screens, Reusable BariWidgets, BLoC / Cubit State)     │
└──────────────────────────────┬──────────────────────────────┘
                               │ depends on
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│     (Entities, Repository Interfaces, UseCases)             │
│   * Pure Dart — Zero Flutter UI, Zero Dio, Zero JSON *      │
└──────────────────────────────▲──────────────────────────────┘
                               │ implemented by
┌──────────────────────────────┴──────────────────────────────┐
│                       DATA LAYER                            │
│  (Models/DTOs, RemoteDataSources, MockDataSources, Repos)   │
│       * Handles DRF snake_case JSON, Dio, GeoJSON *         │
└─────────────────────────────────────────────────────────────┘
```

### Layer Constraints & Prohibitions
1. **Domain Layer Independence:**
   - Files under `lib/features/<feature>/domain/` MUST NOT import `flutter/material.dart`, `dio`, `dart:io`, or any data-layer file.
   - Entities MUST be immutable and extend `Equatable`.
   - Repositories in Domain are abstract contracts (`abstract class AuthRepository`, `abstract class PropertyRepository`).

2. **Data Layer Encapsulation:**
   - DTOs under `lib/features/<feature>/data/models/` map JSON from Django REST Framework (DRF) to Domain entities.
   - All serialization (`fromJson`, `toJson`) and deserialization belongs strictly in the Data layer.
   - DTOs MUST provide `toEntity()` or `toDomain()` methods to bridge into Domain entities.

3. **Presentation Layer Isolation:**
   - UI Widgets and Screens MUST NOT make direct calls to DataSources, Repositories, or Dio clients.
   - All state transitions and side effects MUST flow through **BLoC / Cubit** via domain **UseCases**.
   - Screens only consume BLoC States and dispatch BLoC Events.

---

## 🔄 2. The Zero-Rework Contract Mandate

The application is engineered so that toggling between simulated mock mode and the live Django REST backend requires changing only one boolean flag:

```dart
// lib/core/config/app_environment.dart
AppEnvironment.useMockData = false; // Connects to Django REST Framework
AppEnvironment.useMockData = true;  // Uses high-fidelity Mock Data Sources
```

### Golden Invariants for Zero-Rework:
1. **Identical Repository Signatures:**
   Both `PropertyRemoteDataSource` and `PropertyMockDataSource` must implement the exact same methods returning identical Data Models.
2. **Repository Implementation Switching:**
   Every `RepositoryImpl` must accept both `remoteDataSource` and `mockDataSource`, selecting between them based solely on `AppEnvironment.useMockData`:
   ```dart
   @override
   Future<List<Property>> getProperties({String? category, String? area, double? maxRent}) async {
     try {
       final models = AppEnvironment.useMockData
           ? await mockDataSource.getProperties(category: category, area: area, maxRent: maxRent)
           : await remoteDataSource.getProperties(category: category, area: area, maxRent: maxRent);
       return models.map((m) => m.toDomain()).toList();
     } on DioException catch (e) {
       throw ServerException.fromDio(e);
     }
   }
   ```
3. **Zero UI/BLoC Impact:**
   Switching `AppEnvironment.useMockData` MUST NOT require any modification in BLoC, Cubit, Domain Entities, UseCases, or UI Screens.

---

## 🌐 3. Network Stack & JWT Standards

All HTTP communication with the Django REST Framework backend uses `DioClient` with centralized interceptors.

### 3.1 Base URLs & Device Configuration
- **Android Emulator:** `http://10.0.2.2:8000/api/v1`
- **iOS Simulator / macOS Desktop:** `http://127.0.0.1:8000/api/v1`
- **Physical Device (Local Wi-Fi):** `http://<YOUR_LOCAL_IP>:8000/api/v1`
- **Production Server:** `https://api.rentbd.com/api/v1`

### 3.2 Bearer Token Lifecycle
- `AuthInterceptor` automatically injects `Authorization: Bearer <access_token>` into every protected request.
- Tokens are stored securely using `FlutterSecureStorage` or shared auth state.
- On HTTP `401 Unauthorized`:
  1. The interceptor intercepts the failure.
  2. Attempts token refresh via `POST /api/v1/auth/token/refresh/` using the stored refresh token.
  3. If refresh succeeds, replays the original failed request with the new access token.
  4. If refresh fails, triggers `SignOutRequestedEvent` to safely redirect the user to login.

### 3.3 DRF Pagination Handling
All listing endpoints support DRF `PageNumberPagination`. Responses return:
```json
{
  "count": 48,
  "next": "http://10.0.2.2:8000/api/v1/properties/?page=2",
  "previous": null,
  "results": [ ... ]
}
```
Use `DrfPaginatedResponse<T>` from `lib/core/network/drf_paginated_response.dart` to deserialize paginated results.

### 3.4 Network Observability: Green Dio Logger & Chucker
- **RentBdDioLogger (`lib/core/network/dio_logger_interceptor.dart`):** Custom ANSI Emerald Green terminal logger displaying formatted box borders, request methods, endpoints, sanitized headers, pretty-printed JSON payloads, status badges, and roundtrip duration in milliseconds.
- **Chucker Flutter (`chucker_flutter: ^1.9.2`):** In-app HTTP inspector active in debug mode (`kDebugMode`) via `ChuckerDioInterceptor` on `DioClient` and `ChuckerFlutter.navigatorKey` on `GoRouter`.

---

## 🛡️ 4. Landlord-Only KYC & Rent Creation Gating Rules

### 4.1 Landlord-Only KYC Architecture
In accordance with platform owner safety standards and DMP / CIMS rental regulations:
1. **Tenants (ভাড়াটিয়া):**
   - Free and friction-free experience. Zero mandatory KYC requirements.
   - Tenants can browse, filter, inspect, schedule visits, initiate masked chat, and generate rent agreements without any KYC blockers or intrusive banners.
2. **Landlords (বাড়িওয়ালা / ফ্ল্যাট মালিক):**
   - **Frictionless Registration & Login:** Landlords can register and sign in immediately with phone/OTP or password without upfront KYC.
   - **Profile-Centric KYC:** NID verification is placed within the **Profile** screen (`/profile` -> `/auth/kyc`).
   - **Strict Rent Creation Gating:** When a landlord attempts to **create, publish, or list a property** (`QuickPostScreen`, `PropertyVaultScreen` flat addition, or toggling a flat to "Available"):
     - The app checks `user.isKycCompleted` (`isNidVerified == true` or `kycStatus == KycStatus.verified`).
     - **If verified:** The action proceeds smoothly.
     - **If unverified:** The action is strictly blocked, presenting a blocking dialog explaining that landlord NID verification is mandatory before advertising properties, with 1-tap navigation to `/auth/kyc`.

### 4.2 Role-Based Segregation (`tenant` vs `landlord`)
- **Tenant Mode:**
  - Exploration feed, Saved properties, Visit schedules, Digital rent payment ledger.
- **Landlord Mode:**
  - Property Vault (1-tap vacancy toggle guarded by KYC), Quick Post listing (guarded by KYC), Tenant screening inbox, Bill issuance.
- **Dual Users:**
  - Can switch roles dynamically via `/api/v1/auth/role/switch/`.
  - Bottom navigation bar (`ShellRoute`) adapts instantly between Tenant and Landlord tab configurations.

---

## 📦 5. Feature-by-Feature Implementation Protocol

When implementing any feature from `api_documentation.md`:

### Step 1: Model & DTO Creation (`data/models/`)
- Create `<name>_model.dart` matching the DRF response schema.
- Use `snake_case` in JSON keys (`created_at`, `rent_amount`, `is_available`).
- Handle null safety with robust defaults or nullable types.
- Implement `toDomain()` mapping to the Domain Entity.
- Add unit tests in `test/models/<name>_model_test.dart`.

### Step 2: Data Source Contract (`data/datasources/`)
- Add method signature to `<feature>_remote_datasource.dart`.
- Implement Dio call with proper endpoint, query parameters, and headers.
- Mirror the method in `<feature>_mock_datasource.dart` with high-fidelity realistic Dhaka mock data.

### Step 3: Domain Repository & UseCase (`domain/`)
- Declare method in `<feature>_repository.dart`.
- Create discrete, single-responsibility UseCase class in `domain/usecases/` (e.g. `ScheduleVisitUseCase`, `ComparePropertiesUseCase`).

### Step 4: Repository Implementation (`data/repositories/`)
- Implement method in `<feature>_repository_impl.dart`.
- Route through `AppEnvironment.useMockData` to choose between remote and mock data sources.
- Catch `DioException` and rethrow typed `ServerException` or return domain `Failure`.

### Step 5: BLoC / Cubit State Management (`presentation/bloc/`)
- Add Event in `<feature>_event.dart`.
- Add States in `<feature>_state.dart` (`Initial`, `Loading`, `Loaded`, `Error`).
- Handle event in `<feature>_bloc.dart` by invoking the UseCase and emitting states.

### Step 6: Presentation UI & Routing (`presentation/screens/`)
- Bind UI widgets to BLoC states using `BlocBuilder` / `BlocConsumer`.
- Use pre-built design system widgets (`BariButton`, `BariCard`, `BariBadge`, `BariPriceTag`, `BariTextField`).
- Register route in `lib/core/router/route_names.dart` and `app_router.dart`.

### Step 7: Verification & Testing
- Run `flutter analyze` — ensure **0 issues**.
- Run `flutter test` — ensure all unit and widget tests pass.

---

## 🎨 6. Design System & Bangladeshi Localization Invariants

1. **Colors & Themes:**
   - Primary: Emerald Green (`#059669` / `AppColors.primary`).
   - Secondary: Deep Amber (`#D97706` / `AppColors.secondary`).
   - Dark & Light mode support required on all screens.
2. **Bangladeshi Taka Formatting:**
   - All rent, bills, and charges MUST be displayed in BDT with commas (`৳ 25,000/mo`).
   - Use `BariPriceTag` widget or `AppEnvironment.currencySymbol`.
3. **Bangla & Banglish Support:**
   - Multi-category switch labels: Family (পরিবার), Bachelor (ব্যাচেলর), Sublet (সাবলেট).
   - Natural language search must recognize English, Bangla, and Banglish (e.g., "2 bed mirpur line gas").
4. **GeoDjango / PostGIS Coordinates:**
   - Dhaka default center: `23.8103° N, 90.4125° E`.
   - Longitude is index `0`, Latitude is index `1` in GeoJSON `[lng, lat]`.

---

## 💉 7. Dependency Injection with GetIt (`lib/core/di/service_locator.dart`)

All application dependencies are wired via `GetIt` (`sl` / `getIt`):
1. **Core & Network:** `sl.registerLazySingleton<DioClient>(() => DioClient())`
2. **Data Sources:** Registered as lazy singletons (`Mock` and `Remote`).
3. **Repositories:** Registered against their abstract Domain contracts, injecting both data sources via the Zero-Rework Contract (`sl<AuthRepository>()`, `sl<PropertyRepository>()`, etc.).
4. **Use Cases:** Registered as lazy singletons taking repositories directly from `sl()`.
5. **BLoCs:** Registered as factories (`sl.registerFactory(() => AuthBloc(...))`) so each screen or test gets a clean, independent BLoC instance.
6. **Access:** Use `sl<T>()` or `getIt<T>()` across the app, or `ServiceLocator.<service>` for static access.

