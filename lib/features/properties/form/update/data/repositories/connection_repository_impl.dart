// lib/features/properties/put/data/repositories/connection_repository_impl.dart
import 'package:flutter_application/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:flutter_application/features/properties/form/update/data/mappers/connection_mapper.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/connection_repository.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/change_meter_request.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionRemoteDataSource remoteDataSource;

  ConnectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionParams params,
  }) async {
    final request = ConnectionMapper.toRequest(params, connectionId);
    await remoteDataSource.updateConnection(
      connectionId: connectionId,
      request: request,
    );
  }

  @override
  Future<void> changeMeterByReader(ChangeMeterRequest request) async {
    await remoteDataSource.changeMeter(request);
  }
}
