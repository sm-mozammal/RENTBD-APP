import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/widgets/bari_segmented_switch.dart';
import 'package:rentbd_app/features/property/data/datasources/property_mock_datasource.dart';
import 'package:rentbd_app/features/property/data/repositories/property_repository_impl.dart';
import 'package:rentbd_app/features/property/domain/entities/property.dart';
import 'package:rentbd_app/features/property/domain/usecases/property_usecases.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_event.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_state.dart';

void main() {
  group('PropertyBloc Unit & Search Flow', () {
    late PropertyMockDataSource mockDataSource;
    late PropertyRepositoryImpl repository;
    late GetPropertiesUseCase getPropertiesUseCase;
    late GetPropertyByIdUseCase getPropertyByIdUseCase;
    late ToggleSavePropertyUseCase toggleSavePropertyUseCase;
    late GetSavedPropertiesUseCase getSavedPropertiesUseCase;
    late NaturalLanguageSearchUseCase naturalLanguageSearchUseCase;

    setUp(() {
      AppEnvironment.mockDelay = Duration.zero;
      mockDataSource = PropertyMockDataSource();
      repository = PropertyRepositoryImpl(
        mockDataSource: mockDataSource,
        remoteDataSource: mockDataSource,
      );
      getPropertiesUseCase = GetPropertiesUseCase(repository);
      getPropertyByIdUseCase = GetPropertyByIdUseCase(repository);
      toggleSavePropertyUseCase = ToggleSavePropertyUseCase(repository);
      getSavedPropertiesUseCase = GetSavedPropertiesUseCase(repository);
      naturalLanguageSearchUseCase = NaturalLanguageSearchUseCase(repository);
    });

    PropertyBloc buildBloc() {
      return PropertyBloc(
        getPropertiesUseCase: getPropertiesUseCase,
        getPropertyByIdUseCase: getPropertyByIdUseCase,
        toggleSavePropertyUseCase: toggleSavePropertyUseCase,
        getSavedPropertiesUseCase: getSavedPropertiesUseCase,
        naturalLanguageSearchUseCase: naturalLanguageSearchUseCase,
      );
    }

    test('initial state is PropertyInitial', () {
      expect(buildBloc().state, equals(const PropertyInitial()));
    });

    blocTest<PropertyBloc, PropertyState>(
      'emits [PropertyLoading, PropertyLoaded] when FetchPropertiesEvent is dispatched',
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchPropertiesEvent()),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<PropertyLoading>(),
        isA<PropertyLoaded>().having(
          (s) => s.properties.isNotEmpty,
          'has properties',
          isTrue,
        ),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'filters properties by bachelor tenant type',
      build: buildBloc,
      act: (bloc) => bloc.add(const FilterCategoryChangedEvent(TenantCategoryFilter.bachelor)),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<PropertyLoading>(),
        isA<PropertyLoaded>().having(
          (s) => s.properties.every(
            (p) =>
                p.tenantCategory == TenantCategory.bachelorMale ||
                p.tenantCategory == TenantCategory.bachelorFemale ||
                p.tenantCategory == TenantCategory.any,
          ),
          'only bachelor friendly properties',
          isTrue,
        ),
      ],
    );

    blocTest<PropertyBloc, PropertyState>(
      'executes natural language search like "2 bed mirpur line gas"',
      build: buildBloc,
      act: (bloc) => bloc.add(const VoiceNaturalSearchEvent('2 bed mirpur line gas')),
      expect: () => [
        isA<PropertyLoading>(),
        isA<PropertyLoaded>().having(
          (s) => s.isNaturalSearchActive,
          'natural search active',
          isTrue,
        ),
      ],
    );
    blocTest<PropertyBloc, PropertyState>(
      'clears tenant category filter when switching from family to all',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const FilterCategoryChangedEvent(TenantCategoryFilter.family));
        bloc.add(const FilterCategoryChangedEvent(TenantCategoryFilter.all));
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state, isA<PropertyLoaded>());
        final state = bloc.state as PropertyLoaded;
        expect(state.activeCategory, equals(TenantCategoryFilter.all));
        expect(state.filter.tenantCategory, isNull);
        expect(state.filter.propertyType, isNull);
        expect(state.properties.isNotEmpty, isTrue);
      },
    );
  });
}
