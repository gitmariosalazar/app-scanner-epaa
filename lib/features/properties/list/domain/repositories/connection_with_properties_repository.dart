import 'package:flutter_application/features/properties/list/domain/entities/connection.dart';

abstract class ConnectionWithPropertiesRepository {
  Future<ConnectionEntity> getConnectionWithPropertiesByCadastralKey(
    String cadastralKey,
  );
}
