import 'package:flutter_application/features/form/data/datasources/photo_reading_datasource.dart';
import 'package:flutter_application/features/form/data/repositories/photo_reading_repository_impl.dart';
import 'package:flutter_application/features/form/domain/repositories/photo_reading_repository.dart';
import 'package:flutter_application/features/form/domain/usecases/create_photo_reading_use_case.dart';
import 'package:flutter_application/features/form/presentation/blocs/photo-readings/photo_reading_bloc.dart';
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart';

import 'package:flutter_application/features/observations/data/datasources/observations_datasource.dart';
import 'package:flutter_application/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:flutter_application/features/observations/domain/repositories/observation_repository.dart';
import 'package:flutter_application/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:flutter_application/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';

import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:flutter_application/features/reading/data/datasources/remote_reading_data_source.dart';
import 'package:flutter_application/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:flutter_application/features/reading/domain/repositories/reading_repository.dart';
import 'package:flutter_application/features/reading/domain/usecases/get_reading_info.dart';
import 'package:flutter_application/features/reading/presentation/scan/bloc/reading_scan_bloc.dart';
import 'package:flutter_application/features/reading/presentation/manually/blocs/reading_manually_bloc.dart';
import 'package:flutter_application/features/work-orders/data/datasources/work_order_remote_datasource.dart';
import 'package:flutter_application/features/work-orders/data/repositories/work_order_repository_impl.dart';
import 'package:flutter_application/features/work-orders/domain/repositories/work_order_repository.dart';
import 'package:flutter_application/features/work-orders/domain/usecases/create_work_order.dart';
import 'package:flutter_application/features/work-orders/presentation/blocs/create_work_order/create_work_order_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================
  // EXTERNAL DEPENDENCIES
  // ==========================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // ==========================
  // AUTH FEATURE
  // ==========================
  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // ==========================
  // READING FEATURE
  // ==========================
  // Data sources
  sl.registerLazySingleton<RemoteReadingDataSource>(
    () => RemoteReadingDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ReadingRepository>(
    () => ReadingRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton<GetReadingInfo>(() => GetReadingInfo(sl()));

  // Blocs
  sl.registerFactory(() => ReadingScanBloc(sl()));
  sl.registerFactory(() => ReadingManuallyBloc(sl()));

  // ==========================
  // FORM FEATURE
  // ==========================
  // Data sources
  sl.registerLazySingleton<PhotoReadingDataSource>(
    () => PhotoReadingDataSource(),
  );

  // Repository
  sl.registerLazySingleton<PhotoReadingRepository>(
    () => PhotoReadingRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton<CreatePhotoReadingUseCase>(
    () => CreatePhotoReadingUseCase(sl()),
  );

  // Blocs
  sl.registerFactory(() => PhotoReadingBloc(sl()));
  sl.registerFactory(() => FormBloc());

  // ==========================
  // OBSERVATIONS FEATURE
  // ==========================
  // Data sources
  sl.registerLazySingleton<ObservationsDataSource>(
    () => ObservationsDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<ObservationRepository>(
    () => ObservationRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton<FindAllObservationsUseCase>(
    () => FindAllObservationsUseCase(sl()),
  );
  sl.registerLazySingleton<FindAllObservationsByCadastralKeyUseCase>(
    () => FindAllObservationsByCadastralKeyUseCase(sl()),
  );

  // Bloc
  sl.registerFactory(
    () => ObservationBloc(
      sl<FindAllObservationsUseCase>(),
      sl<FindAllObservationsByCadastralKeyUseCase>(),
    ),
  );

  // ==========================
  // WORK ORDERS FEATURE
  // ==========================
  // Blocs
  // Note: The registration of CreateWorkOrderBloc is assumed to be here
  // as it is used in other parts of the application.

  // === REPOSITORY ===
  sl.registerLazySingleton<WorkOrderRemoteDataSource>(
    () => WorkOrderRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<WorkOrderRepository>(
    () => WorkOrderRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => CreateWorkOrderUseCase(sl()));

  sl.registerFactory<CreateWorkOrderBloc>(
    () => CreateWorkOrderBloc(createWorkOrder: sl()),
  );
}
