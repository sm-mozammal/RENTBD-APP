# RentBD — API Implementation Guide (Feature-by-Feature)

This guide provides a comprehensive, production-grade roadmap for integrating the **RentBD Django REST Framework (DRF) + GeoDjango/PostGIS backend** into the **RentBD Flutter Mobile App**.

Every feature is implemented following strict **Clean Architecture (Domain, Data, Presentation)** to maintain the **Zero-Rework Contract**: toggling `AppEnvironment.useMockData` between `true` and `false` switches instantly between realistic simulated data and the live Django REST backend without modifying a single line of UI, State Management, or Domain code.

---

## 📑 Table of Contents

1. [Architecture Foundations & Setup](#1-architecture-foundations--setup)
2. [Module 1: Authentication & User Profiles (`/api/v1/auth/`)](#2-module-1-authentication--user-profiles)
3. [Module 2: Property Listings & Operations (`/api/v1/properties/`)](#3-module-2-property-listings--operations)
4. [Module 3: AI Tools & Location Intelligence (`/api/v1/properties/`)](#4-module-3-ai-tools--location-intelligence)
5. [Module 4: Inquiries & Visit Bookings (`/api/v1/inquiries/`)](#5-module-4-inquiries--visit-bookings)
6. [Module 5: Crowdsourced Area Insights (`/api/v1/insights/`)](#6-module-5-crowdsourced-area-insights)
7. [Module 6: Digital Rent & Utility Ledger (`/api/v1/ledger/`)](#7-module-6-digital-rent--utility-ledger)
8. [Module 7: Encrypted Chat & Masked Calling (`/api/v1/chat/`)](#8-module-7-encrypted-chat--masked-calling)
9. [Verification, Quality Assurance & Testing Standards](#9-verification-quality-assurance--testing-standards)

---

## 1. Architecture Foundations & Setup

### 1.1 The Clean Architecture Data Flow
Every API call follows this strict unidirectional path:

```
[UI Screen / Widget]
       │
       ▼ (Dispatches Event)
[BLoC / Cubit]
       │
       ▼ (Executes)
[Domain UseCase]
       │
       ▼ (Invokes abstract contract)
[Domain Repository Interface]
       │
       ▼ (Implemented by)
[Data RepositoryImpl] ─── checks ───► AppEnvironment.useMockData?
       ├─── (true)  ──► [MockDataSource]   (Simulated Latency & Fixtures)
       └─── (false) ──► [RemoteDataSource] (Dio HTTP Client + AuthInterceptor)
                              │
                              ▼ (HTTP REST Request)
                    [Django REST Framework Backend]
```

### 1.2 Base URL & Environment Configuration
Set in `lib/core/config/app_environment.dart`:

```dart
class AppEnvironment {
  // Toggle between simulated mock data and live Django REST API
  static bool useMockData = false; // Set to false to hit live backend

  // Base API URL
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1'; // Android Emulator alias
    return 'http://127.0.0.1:8000/api/v1'; // iOS Simulator / macOS
  }
}
```

### 1.3 Dio Client & Auth Interceptor
Managed in `lib/core/network/`:
- `dio_client.dart`: Pre-configured Dio instance with timeouts and logging.
- `auth_interceptor.dart`: Automatically attaches `Authorization: Bearer <access_token>`. On HTTP `401`, triggers token refresh via `/api/v1/auth/token/refresh/` or redirects to login.
- `drf_paginated_response.dart`: Generic parser for Django `PageNumberPagination`:
  ```dart
  class DrfPaginatedResponse<T> {
    final int count;
    final String? next;
    final String? previous;
    final List<T> results;
    // ...
  }
  ```

---

## 2. Module 1: Authentication & User Profiles

### Overview
Handles Bangladeshi mobile OTP login, password registration/login, user profile updates, Landlord KYC (NID verification), and dynamic Tenant/Landlord role switching.

### Feature 1.1: Request Mobile OTP
- **Endpoint:** `POST /api/v1/auth/otp/request/`
- **Auth:** Public (`AllowAny`)
- **Request Body:** `{"phone_number": "+8801712345678"}`
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "OTP sent successfully to +8801712345678",
    "expires_in_seconds": 300,
    "dev_otp": "123456"
  }
  ```
- **Implementation Steps:**
  1. **Data Layer:** `AuthRemoteDataSource.sendOtp(phone)` dispatches `POST /auth/otp/request/`.
  2. **Domain Layer:** `SendOtpUseCase` executes with phone parameter.
  3. **Presentation Layer:** `AuthBloc` handles `SendOtpRequestedEvent` and transitions `AuthState` to `OtpSentState`.
  4. **UI:** `LoginOtpScreen` presents 6-digit OTP input pin fields.

### Feature 1.2: Verify OTP & Auto-Provision Account
- **Endpoint:** `POST /api/v1/auth/otp/verify/`
- **Auth:** Public (`AllowAny`)
- **Request Body:** `{"phone_number": "+8801712345678", "otp_code": "123456", "role": "tenant"}`
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "tokens": {"access": "eyJ...", "refresh": "eyJ..."},
    "user": {
      "id": "uuid",
      "phone_number": "+8801712345678",
      "full_name": "Rahim Ahmed",
      "role": "tenant",
      "tenant_profile": {"nid_status": "not_submitted"}
    }
  }
  ```
- **Implementation Steps:**
  1. Save JWT `access` and `refresh` tokens to `FlutterSecureStorage`.
  2. Map `user` into `UserProfileModel` -> `UserProfile` domain entity.
  3. **Role Routing:** Tenants navigate to home exploration feed; landlords navigate to landlord vault. Neither role is forced to complete KYC upfront on login.

### Feature 1.3: User Registration & Password Login
- **Endpoints:**
  - Register: `POST /api/v1/auth/register/` (Body: `phone_number`, `password`, `full_name`, `role`, `email`)
  - Login: `POST /api/v1/auth/login/` (Body: `phone_number`, `password`)
- **Implementation Steps:**
  1. `RegisterUseCase` and `LoginWithPasswordUseCase` call `AuthRepository`.
  2. `RegisterScreen` collects credentials with role selection (ভাড়াটিয়া / বাড়িওয়ালা).

### Feature 1.4: User Profile Read & Update
- **Endpoints:**
  - Read: `GET /api/v1/auth/profile/`
  - Update: `PATCH /api/v1/auth/profile/` (Body: `full_name`, `email`, `occupation`, `workplace`, `family_members_count`)
- **Implementation Steps:**
  1. `UserProfileModel` handles both `tenant_profile` and `landlord_profile` sub-dictionaries.
  2. `ProfileScreen` opens the update profile modal and dispatches `UpdateProfileRequestedEvent`.

### Feature 1.5: Landlord KYC Submission & Verification (বাড়িওয়ালা NID ভেরিফিকেশন)
- **Endpoint:** `POST /api/v1/auth/kyc/submit/`
- **Location:** Accessible from Profile (`ProfileScreen` -> `/auth/kyc`).
- **Enforcement:** Checked when landlords publish listings (`QuickPostScreen`) or post/toggle flats to "Available" (`PropertyVaultScreen`). Unverified landlords are blocked from listing until KYC is verified.
- **Auth:** Bearer Token
- **Request Body (Multipart or JSON):**
  - `nid_number`: 10 or 17 digit national identity number.
  - `date_of_birth`: `YYYY-MM-DD`.
  - `nid_front`, `nid_back`: Photo uploads.
  - `cims_emergency_contact`: Emergency phone number.
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "kyc_status": "verified",
    "is_nid_verified": true,
    "message": "NID verified successfully via Election Commission database."
  }
  ```
- **Implementation Steps:**
  1. `KycVerificationScreen` collects NID details and uploads.
  2. `SubmitKycUseCase` dispatches `SubmitKycRequestedEvent`.
  3. Updates `AuthBloc` state with `isNidVerified: true`, unlocking visits and chat barriers across the app.

### Feature 1.6: Instant Role Switch
- **Endpoint:** `POST /api/v1/auth/role/switch/`
- **Request Body:** `{"role": "landlord"}`
- **Response (200 OK):** Returns updated user profile with active role.
- **Implementation Steps:**
  1. `SwitchRoleUseCase` executes.
  2. BLoC updates active role; `app_router.dart` dynamically morphs bottom navigation between Tenant and Landlord tabs.

---

## 3. Module 2: Property Listings & Operations

### Feature 2.1: Property Discovery Feed with Category Switches
- **Endpoint:** `GET /api/v1/properties/`
- **Query Parameters:**
  - `tenant_category`: `BACHELOR`, `FAMILY`, `SUBLET`
  - `area`: `Mirpur`, `Uttara`, `Dhanmondi`, `Gulshan`, etc.
  - `min_rent`, `max_rent`: Price bounds in BDT (৳).
  - `bedrooms`: Number of bedrooms.
  - `page`: Pagination index (DRF `PageNumberPagination`).
- **Response (200 OK):**
  ```json
  {
    "count": 28,
    "next": "http://10.0.2.2:8000/api/v1/properties/?page=2",
    "previous": null,
    "results": [
      {
        "id": "prop-mirpur-01",
        "title": "Modern 3-Bed Family Apartment",
        "rent_amount": "25000.00",
        "bedrooms": 3,
        "bathrooms": 2,
        "square_feet": 1250,
        "location": {"type": "Point", "coordinates": [90.3683, 23.8067]},
        "area_neighborhood": "Mirpur 10",
        "fair_price_status": "FAIR_PRICE",
        "bachelor_allowed": false,
        "sublet_allowed": false,
        "is_available": true,
        "images": [{"image_url": "https://...", "is_verified_photo": true}]
      }
    ]
  }
  ```
- **Implementation Steps:**
  1. **DTO:** `PropertyModel.fromJson` parses PostGIS GeoJSON coordinates `[lng, lat]` into `latitude = coords[1]`, `longitude = coords[0]`.
  2. **Repository:** `PropertyRepositoryImpl.getProperties()` invokes `PropertyRemoteDataSource.getProperties()`.
  3. **Presentation:** `PropertyBloc` handles `FetchPropertiesEvent` and `FilterCategoryChangedEvent`.
  4. **UI:** `HomeScreen` renders 1-tap category segmented switches and skeleton loading shimmer.

### Feature 2.2: Quick Post Property (Landlord Only)
- **Endpoint:** `POST /api/v1/properties/quick-post/` (or `/api/v1/properties/`)
- **Auth:** Landlord Bearer Token (`IsAuthenticated`, role=`landlord`)
- **Request Body:**
  ```json
  {
    "title": "Sunny 2BHK Apartment",
    "property_type": "APARTMENT",
    "tenant_category": "FAMILY",
    "rent_amount": 22000.0,
    "security_deposit": 44000.0,
    "service_charge": 3500.0,
    "area_neighborhood": "Uttara Sector 4",
    "full_address": "House 12, Road 5",
    "latitude": 23.8681,
    "longitude": 90.3984,
    "bedrooms": 2,
    "bathrooms": 2,
    "balconies": 1,
    "square_feet": 1050,
    "gas_supply": "LINE_GAS"
  }
  ```
- **Implementation Steps:**
  1. Guarded by role validation in `QuickPostScreen` (tenants cannot publish).
  2. `CreatePropertyUseCase` sends payload to `PropertyRemoteDataSource.quickPost()`.
  3. On success, refreshes Landlord Property Vault.

### Feature 2.3: 1-Tap Re-Listing (Property Vault)
- **Endpoint:** `POST /api/v1/properties/{id}/vault/`
- **Description:** Toggles `is_available` between `true` (Available) and `false` (Rented).
- **Implementation Steps:**
  1. `TogglePropertyVaultUseCase` calls endpoint.
  2. `PropertyVaultScreen` updates listing status badge in real time.

### Feature 2.4: Save Property (Wishlist) & Saved Properties List
- **Endpoints:**
  - Toggle Save: `POST /api/v1/properties/{id}/save/`
  - Get Saved: `GET /api/v1/properties/saved/`
- **Implementation Steps:**
  1. `ToggleSavePropertyUseCase` and `GetSavedPropertiesUseCase` manage favorite status.
  2. `SavedPropertiesScreen` displays tenant's shortlisted homes.

### Feature 2.5: Geo-Tagged Live Photo Upload (Live Camera EXIF)
- **Endpoint:** `POST /api/v1/properties/{id}/photos/upload/`
- **Body:** Multipart `photo` file.
- **Backend Action:** Inspects EXIF GPS metadata. If valid, flags image as `is_verified_photo: true`.
- **Implementation Steps:**
  1. Mobile camera captures photo with geolocation enabled.
  2. Dispatches multipart POST request to upload endpoint.

---

## 4. Module 3: AI Tools & Location Intelligence

### Feature 3.1: AI Natural Language & Voice Search
- **Endpoint:** `GET /api/v1/properties/ai-search/?q=2+bed+mirpur+10+line+gas+within+18000`
- **Supports:** English, Bangla (বাংলা), and Banglish.
- **Implementation Steps:**
  1. `NaturalLanguageSearchUseCase` dispatches query to `PropertyRemoteDataSource.searchByNaturalLanguage()`.
  2. `PropertyBloc` handles `VoiceNaturalSearchEvent`.
  3. `HomeScreen` displays parsed criteria badge and filtered results.

### Feature 3.2: AI Fair Rent Meter
- **Endpoint:** `GET /api/v1/properties/{id}/fair-rent-meter/`
- **Response (200 OK):**
  ```json
  {
    "property_id": "prop-mirpur-01",
    "fair_price_status": "GREAT_DEAL",
    "fair_price_percent_diff": -8.5,
    "actual_rent": 25000.0,
    "area_benchmark_rent": 27300.0,
    "ai_verdict": "This flat is 8.5% below the Mirpur 10 market average! Highly recommended."
  }
  ```
- **Implementation Steps:**
  1. `PropertyDetailScreen` displays AI valuation badge (`GREAT_DEAL`, `FAIR_PRICE`, `OVERPRICED`) with comparison breakdown.

### Feature 3.3: Side-by-Side Property Comparison Matrix
- **Endpoint:** `POST /api/v1/properties/compare/`
- **Request Body:**
  ```json
  {
    "property_ids": ["prop-mirpur-01", "prop-uttara-02"],
    "destination_lat": 23.7461,
    "destination_lng": 90.3742,
    "destination_name": "Kawran Bazar Office"
  }
  ```
- **Response (200 OK):** Side-by-side comparison matrix across rent, sqft, floor level, utilities, move-in cost, and peak rush hour commute times.
- **Implementation Steps:**
  1. `PropertyComparisonScreen` renders multi-column matrix with color-coded advantages.

### Feature 3.4: Upfront Move-in Cost Calculator
- **Endpoint:** `POST /api/v1/properties/move-in-calculator/`
- **Request Body:**
  ```json
  {
    "property_id": "prop-mirpur-01",
    "moving_distance_km": 7.5,
    "truck_type": "PICKUP_SMALL",
    "needs_labour": true
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "security_deposit_advance": 50000.0,
    "first_month_rent": 25000.0,
    "service_charge": 3500.0,
    "estimated_utilities": 2500.0,
    "moving_and_labour_estimate": 4800.0,
    "total_upfront_cash_required": 85800.0
  }
  ```
- **Implementation Steps:**
  1. `MoveInCalculatorModal` in `PropertyDetailScreen` allows tenants to adjust distance and moving options to see the exact cash needed on day one.

### Feature 3.5: Draw-on-Map Custom Polygon Search
- **Endpoint:** `POST /api/v1/properties/draw-search/`
- **Request Body:**
  ```json
  {
    "polygon": [
      [23.8050, 90.3650],
      [23.8120, 90.3680],
      [23.8080, 90.3750],
      [23.8010, 90.3710]
    ]
  }
  ```
- **Implementation Steps:**
  1. Tenant draws a polygon contour on Google Maps with their finger.
  2. Transmits coordinates to backend; backend uses ray-casting / PostGIS `ST_Contains` to return properties inside the custom boundary.

### Feature 3.6: Office / University Commute & Metro Calculator
- **Endpoint:** `POST /api/v1/properties/commute-calculator/`
- **Request Body:**
  ```json
  {
    "property_id": "prop-mirpur-01",
    "destination_lat": 23.7508,
    "destination_lng": 90.3934,
    "destination_name": "Farmgate Metro",
    "travel_mode": "METRO_TRANSIT"
  }
  ```
- **Response:** Returns Metro transit minutes, peak car driving traffic time, CNG time, and walking estimates.

### Feature 3.7: Nearby Essentials (500m Walkability Layer)
- **Endpoint:** `GET /api/v1/properties/{id}/nearby-essentials/`
- **Response:** Walking distance in meters and minutes to nearest Metro Station, Bus Stand, Mosque, Grocery Bazar, Hospital, and ATM.

### Feature 3.8: AI Rent Agreement Generator
- **Endpoint:** `POST /api/v1/properties/ai-rent-agreement/`
- **Auth:** Mandatory Verified Tenant KYC
- **Request Body:**
  ```json
  {
    "property_id": "prop-mirpur-01",
    "tenant_name": "Rahim Ahmed",
    "tenant_phone": "+8801712345678",
    "tenant_nid": "19922692019000123",
    "agreed_rent": 25000.0,
    "security_deposit": 50000.0,
    "start_date": "2026-11-01",
    "duration_months": 12
  }
  ```
- **Response:** Ready-to-print legal tenancy agreement in Markdown and HTML adhering to Bangladesh Tenancy Laws.

---

## 5. Module 4: Inquiries & Visit Bookings

### Feature 4.1: Schedule Property Visit
- **Endpoint:** `POST /api/v1/inquiries/visits/`
- **Auth:** Tenant Bearer Token (Mandatory KYC Verified)
- **Request Body:**
  ```json
  {
    "property_id": "prop-mirpur-01",
    "scheduled_date": "2026-10-25",
    "time_slot": "10:30 AM - 11:30 AM",
    "visit_type": "IN_PERSON",
    "notes": "Looking for immediate move-in."
  }
  ```
- **Enforcement:**
  If tenant is unverified, UI blocks booking and presents KYC modal.
- **Implementation Steps:**
  1. `VisitSchedulerScreen` displays available time slots.
  2. Dispatches `BookVisitRequestedEvent` to `VisitBloc`.
  3. Displays confirmation with booking ID.

### Feature 4.2: My Booked Visits (Tenant) & Visit Requests (Landlord)
- **Endpoint:** `GET /api/v1/inquiries/visits/my/`
- **Response:** Returns list of pending, confirmed, rescheduled, and completed visits.
- **Landlord Actions:** Landlord can accept (`CONFIRMED`) or reschedule (`RESCHEDULED`) directly from `TenantScreeningScreen`.

---

## 6. Module 5: Crowdsourced Area Insights

### Feature 6.1: Area Insights & Quality-of-Life Metrics
- **Endpoint:** `GET /api/v1/insights/area/{area_name}/`
- **Response (200 OK):**
  ```json
  {
    "area_name": "Mirpur 10",
    "waterlogging_risk": "LOW",
    "load_shedding_frequency": "RARE",
    "gas_supply_status": "LINE_GAS_EXCELLENT",
    "night_safety_rating": 4.6,
    "broadband_isp_rating": 4.8,
    "total_verified_reviews": 42
  }
  ```
- **Implementation Steps:**
  1. Displayed in `PropertyDetailScreen` under "Dhaka Hyper-Local Living Intelligence".
  2. Informs tenants about monsoon flooding, line gas reliability, and evening security.

### Feature 6.2: Submit Verified Tenant Area Review
- **Endpoint:** `POST /api/v1/insights/reviews/`
- **Body:** Rating scores and review notes submitted by verified residents.

---

## 7. Module 6: Digital Rent & Utility Ledger

### Feature 7.1: Active Leases & Monthly Bills List
- **Endpoints:**
  - Leases: `GET /api/v1/ledger/leases/`
  - Bills: `GET /api/v1/ledger/bills/`
- **Response (200 OK):**
  ```json
  [
    {
      "id": "bill-oct-2026",
      "lease_id": "lease-01",
      "month_year": "October 2026",
      "rent_amount": 25000.0,
      "service_charge": 3500.0,
      "electricity_bill": 1850.0,
      "gas_bill": 1080.0,
      "total_amount": 31430.0,
      "due_date": "2026-10-10",
      "payment_status": "PAID",
      "paid_at": "2026-10-08T14:30:00Z",
      "transaction_id": "BKASH-TRX-998822"
    }
  ]
  ```
- **Implementation Steps:**
  1. `RentLedgerScreen` renders monthly billing cards with status badges (PAID, DUE, OVERDUE).

### Feature 7.2: Issue Rent Bill (Landlord)
- **Endpoint:** `POST /api/v1/ledger/bills/`
- **Auth:** Landlord Bearer Token
- **Body:** Breakdown of rent, service charge, electricity sub-meter units, gas, and water.

### Feature 7.3: Pay Rent Bill with bKash / Nagad
- **Endpoint:** `POST /api/v1/ledger/bills/{id}/pay/`
- **Request Body:**
  ```json
  {
    "payment_method": "BKASH",
    "transaction_id": "9A8B7C6D5E",
    "amount_paid": 31430.0
  }
  ```
- **Response:** Instant digital money receipt with transaction timestamp.

### Feature 7.4: Download Digital Money Receipt PDF
- **Endpoint:** `GET /api/v1/ledger/bills/{id}/receipt/`
- **Response:** Generates signed Bangladeshi rental money receipt PDF.

---

## 8. Module 7: Encrypted Chat & Masked Calling

### Feature 7.1: Encrypted Chat Conversations & Messaging
- **Endpoints:**
  - Conversations: `GET /api/v1/chat/conversations/`
  - Messages: `GET /api/v1/chat/conversations/{id}/messages/`
  - Send: `POST /api/v1/chat/conversations/{id}/messages/`
- **Enforcement:**
  - Unverified tenants CANNOT send messages. `ChatRoomScreen` locks the bottom composer with an amber KYC required barrier.
- **Implementation Steps:**
  1. `ChatListScreen` displays conversations with landlord avatar, property badge, and unread counts.
  2. `ChatRoomScreen` displays real-time messages.

### Feature 7.2: Masked Phone Calling
- **Endpoint:** `POST /api/v1/chat/calls/initiate/`
- **Description:** Dispatches a virtual masked call connecting tenant and landlord without exposing private SIM numbers.
- **Enforcement:** Blocked for unverified tenants.

---

## 9. Verification, Quality Assurance & Testing Standards

### 9.1 Static Code Analysis
Run static analysis before committing any changes:
```bash
flutter analyze
```
**Mandatory standard: 0 errors, 0 warnings, 0 lints.**

### 9.2 Running Automated Test Suite
Run all unit and widget tests:
```bash
flutter test
```
The test suite validates:
1. `test/models/property_model_test.dart`: Validates GeoDjango PostGIS coordinates `[lng, lat]` and DRF snake_case JSON mapping.
2. `test/bloc/auth_bloc_test.dart`: Validates OTP authentication, role switching, and KYC submission states.
3. `test/bloc/property_bloc_test.dart`: Validates category filter switching and AI natural language searches.
4. `test/widgets/bari_widgets_test.dart`: Validates custom UI components (`BariButton`, `BariPriceTag`, `BariBadge`, `BariSegmentedSwitch`).
5. `test/widgets/tenant_kyc_validation_test.dart`: Validates frictionless browsing for tenants, Profile-centric Landlord KYC, and rent creation blocking on `QuickPostScreen` and `PropertyVaultScreen` for unverified landlords.
6. `test/widget_test.dart`: Validates application launch and GoRouter bottom shell navigation.

---

## 🎯 Summary Checklist for Connecting Any Feature

- [ ] **1. DTO Model:** Matches DRF snake_case JSON response in `data/models/`.
- [ ] **2. Data Source:** Remote method in `RemoteDataSource` using `DioClient`; mock method in `MockDataSource`.
- [ ] **3. Domain Contract:** Abstract method in `Repository`; discrete `UseCase` in `domain/usecases/`.
- [ ] **4. Repository Impl:** Routes via `AppEnvironment.useMockData`; handles errors with `ServerException`.
- [ ] **5. BLoC / Cubit:** Handles Event, calls UseCase, emits State (`Initial`, `Loading`, `Loaded`, `Error`).
- [ ] **6. UI Screen:** Consumes BLoC State via `BlocBuilder`/`BlocConsumer`; renders with design system widgets.
- [ ] **7. Verification:** `flutter analyze` passes with 0 issues; `flutter test` passes.
