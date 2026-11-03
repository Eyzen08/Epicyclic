import '../domain/catalog_data.dart';

abstract interface class CatalogRepository {
  Future<CatalogData> loadCatalog();
}
