import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_formatter.dart';
import '../../../../core/widgets/bari_segmented_switch.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/usecases/property_usecases.dart';
import 'property_event.dart';
import 'property_state.dart';

/// Clean Architecture BLoC managing property feed, bachelor/family filter, and natural search.
class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  PropertyBloc({
    required this.getPropertiesUseCase,
    required this.getPropertyByIdUseCase,
    required this.toggleSavePropertyUseCase,
    required this.getSavedPropertiesUseCase,
    required this.naturalLanguageSearchUseCase,
  }) : super(const PropertyInitial()) {
    on<FetchPropertiesEvent>(_onFetchProperties);
    on<FilterCategoryChangedEvent>(_onFilterCategoryChanged);
    on<AreaFilterChangedEvent>(_onAreaFilterChanged);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<VoiceNaturalSearchEvent>(_onVoiceNaturalSearch);
    on<ToggleSaveEvent>(_onToggleSave);
    on<LoadSavedPropertiesEvent>(_onLoadSavedProperties);
    on<ApplyCustomFilterEvent>(_onApplyCustomFilter);
  }

  final GetPropertiesUseCase getPropertiesUseCase;
  final GetPropertyByIdUseCase getPropertyByIdUseCase;
  final ToggleSavePropertyUseCase toggleSavePropertyUseCase;
  final GetSavedPropertiesUseCase getSavedPropertiesUseCase;
  final NaturalLanguageSearchUseCase naturalLanguageSearchUseCase;

  PropertyFilter _currentFilter = const PropertyFilter();
  TenantCategoryFilter _currentCategory = TenantCategoryFilter.all;
  String _currentArea = 'All Dhaka';

  Future<void> _onFetchProperties(
    FetchPropertiesEvent event,
    Emitter<PropertyState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const PropertyLoading());
    }
    try {
      final properties = await getPropertiesUseCase(filter: _currentFilter);
      final currentSaved = state is PropertyLoaded
          ? (state as PropertyLoaded).savedProperties
          : const <Property>[];

      emit(
        PropertyLoaded(
          properties: properties,
          savedProperties: currentSaved,
          activeCategory: _currentCategory,
          activeArea: _currentArea,
          filter: _currentFilter,
        ),
      );
    } catch (e) {
      emit(PropertyError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onFilterCategoryChanged(
    FilterCategoryChangedEvent event,
    Emitter<PropertyState> emit,
  ) async {
    _currentCategory = event.category;

    switch (event.category) {
      case TenantCategoryFilter.family:
        _currentFilter = _currentFilter.copyWith(
          tenantCategory: TenantCategory.family,
          clearPropertyType: true,
        );
        break;
      case TenantCategoryFilter.bachelor:
        _currentFilter = _currentFilter.copyWith(
          tenantCategory: TenantCategory.bachelorMale,
          clearPropertyType: true,
        );
        break;
      case TenantCategoryFilter.sublet:
        // Filter sublets via propertyType
        _currentFilter = _currentFilter.copyWith(
          propertyType: PropertyType.sublet,
          clearCategory: true,
        );
        break;
      case TenantCategoryFilter.all:
        _currentFilter = _currentFilter.copyWith(
          clearCategory: true,
          clearPropertyType: true,
        );
        break;
    }

    add(const FetchPropertiesEvent());
  }

  Future<void> _onAreaFilterChanged(
    AreaFilterChangedEvent event,
    Emitter<PropertyState> emit,
  ) async {
    _currentArea = event.area;
    _currentFilter = _currentFilter.copyWith(
      area: event.area == 'All Dhaka' ? null : event.area,
      clearArea: event.area == 'All Dhaka',
    );
    add(const FetchPropertiesEvent());
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<PropertyState> emit,
  ) async {
    _currentFilter = _currentFilter.copyWith(searchQuery: event.query);
    add(const FetchPropertiesEvent());
  }

  Future<void> _onVoiceNaturalSearch(
    VoiceNaturalSearchEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());
    try {
      final results = await naturalLanguageSearchUseCase(event.naturalQuery);
      emit(
        PropertyLoaded(
          properties: results,
          activeCategory: _currentCategory,
          activeArea: _currentArea,
          filter: _currentFilter,
          isNaturalSearchActive: true,
          naturalSearchPrompt: event.naturalQuery,
        ),
      );
    } catch (e) {
      emit(PropertyError(message: RentBdErrorFormatter.format(e)));
    }
  }

  Future<void> _onToggleSave(
    ToggleSaveEvent event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      await toggleSavePropertyUseCase(event.propertyId);
      final saved = await getSavedPropertiesUseCase();

      if (state is PropertyLoaded) {
        final current = state as PropertyLoaded;
        final updatedList = current.properties.map((p) {
          if (p.id == event.propertyId) {
            return p.copyWith(isSaved: !p.isSaved);
          }
          return p;
        }).toList();

        emit(current.copyWith(
          properties: updatedList,
          savedProperties: saved,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onLoadSavedProperties(
    LoadSavedPropertiesEvent event,
    Emitter<PropertyState> emit,
  ) async {
    try {
      final saved = await getSavedPropertiesUseCase();
      if (state is PropertyLoaded) {
        emit((state as PropertyLoaded).copyWith(savedProperties: saved));
      }
    } catch (_) {}
  }

  Future<void> _onApplyCustomFilter(
    ApplyCustomFilterEvent event,
    Emitter<PropertyState> emit,
  ) async {
    _currentFilter = event.filter;
    add(const FetchPropertiesEvent());
  }
}
