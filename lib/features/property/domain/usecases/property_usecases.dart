import '../entities/property.dart';
import '../entities/property_filter.dart';
import '../repositories/property_repository.dart';

class GetPropertiesUseCase {
  const GetPropertiesUseCase(this._repository);
  final PropertyRepository _repository;

  Future<List<Property>> call({PropertyFilter? filter, int page = 1}) =>
      _repository.getProperties(filter: filter, page: page);
}

class GetPropertyByIdUseCase {
  const GetPropertyByIdUseCase(this._repository);
  final PropertyRepository _repository;

  Future<Property> call(String id) => _repository.getPropertyById(id);
}

class ToggleSavePropertyUseCase {
  const ToggleSavePropertyUseCase(this._repository);
  final PropertyRepository _repository;

  Future<bool> call(String id) => _repository.toggleSaveProperty(id);
}

class GetSavedPropertiesUseCase {
  const GetSavedPropertiesUseCase(this._repository);
  final PropertyRepository _repository;

  Future<List<Property>> call() => _repository.getSavedProperties();
}

class NaturalLanguageSearchUseCase {
  const NaturalLanguageSearchUseCase(this._repository);
  final PropertyRepository _repository;

  Future<List<Property>> call(String query) => _repository.naturalLanguageSearch(query);
}

class CreatePropertyUseCase {
  const CreatePropertyUseCase(this._repository);
  final PropertyRepository _repository;

  Future<Property> call(Map<String, dynamic> propertyData) =>
      _repository.createProperty(propertyData);
}

class ToggleVaultUseCase {
  const ToggleVaultUseCase(this._repository);
  final PropertyRepository _repository;

  Future<bool> call(String propertyId) => _repository.toggleVault(propertyId);
}

