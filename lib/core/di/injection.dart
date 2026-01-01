import 'package:flutter_application/features/form/data/datasources/photo_reading_datasource.dart';
import 'package:flutter_application/features/form/data/repositories/photo_reading_repository_impl.dart';
import 'package:flutter_application/features/form/domain/repositories/photo_reading_repository.dart';
import 'package:flutter_application/features/form/domain/usecases/create_photo_reading_use_case.dart';
import 'package:flutter_application/features/form/presentation/blocs/photo-readings/photo_reading_bloc.dart';
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart';

import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:flutter_application/features/observations/data/datasources/observations_datasource.dart';
import 'package:flutter_application/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:flutter_application/features/observations/domain/repositories/observation_repository.dart';
import 'package:flutter_application/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:flutter_application/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';

import 'package:flutter_application/features/properties/form/add-img/data/datasources/property_image_remote_data_source.dart';
import 'package:flutter_application/features/properties/form/add-img/data/repositories/property_image_repository_impl.dart';
import 'package:flutter_application/features/properties/form/add-img/domain/repositories/property_image_repository.dart';
import 'package:flutter_application/features/properties/form/add-img/domain/usecases/add_property_images.dart';
import 'package:flutter_application/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart';

import 'package:flutter_application/features/properties/list/data/datasources/remote_connection_with_properties_datasource.dart';
import 'package:flutter_application/features/properties/list/data/repositories/connection_with_properties_repository_impl.dart';
import 'package:flutter_application/features/properties/list/domain/usecases/get_connection_with_properties.dart';
import 'package:flutter_application/features/properties/list/presentation/manually/blocs/manually_connection_with_properties_bloc.dart';

import 'package:flutter_application/features/properties/form/update/data/datasources/company_remote_data_source.dart';
import 'package:flutter_application/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:flutter_application/features/properties/form/update/data/datasources/customer_remote_data_source.dart';
import 'package:flutter_application/features/properties/form/update/data/repositories/company_repository_impl.dart';
import 'package:flutter_application/features/properties/form/update/data/repositories/connection_repository_impl.dart';
import 'package:flutter_application/features/properties/form/update/data/repositories/customer_repository_impl.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/company_repository.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/connection_repository.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/customer_repository.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_company.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_connection.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_customer.dart';

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
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // ==========================
  // READING FEATURE
  // ==========================
  sl.registerLazySingleton<RemoteReadingDataSource>(
    () => RemoteReadingDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReadingRepository>(
    () => ReadingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetReadingInfo>(() => GetReadingInfo(sl()));
  sl.registerFactory(() => ReadingScanBloc(sl()));
  sl.registerFactory(() => ReadingManuallyBloc(sl()));

  // ==========================
  // FORM FEATURE
  // ==========================
  sl.registerLazySingleton<PhotoReadingDataSource>(
    () => PhotoReadingDataSource(),
  );
  sl.registerLazySingleton<PhotoReadingRepository>(
    () => PhotoReadingRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<CreatePhotoReadingUseCase>(
    () => CreatePhotoReadingUseCase(sl()),
  );
  sl.registerFactory(() => PhotoReadingBloc(sl()));
  sl.registerFactory(() => FormBloc());

  // ==========================
  // CONNECTION WITH PROPERTIES (para actualización)
  // ==========================
  sl.registerLazySingleton<RemoteConnectionWithPropertiesDataSourceImpl>(
    () => RemoteConnectionWithPropertiesDataSourceImpl(sl<http.Client>()),
  );
  sl.registerLazySingleton<ConnectionWithPropertiesRepositoryImpl>(
    () => ConnectionWithPropertiesRepositoryImpl(
      sl<RemoteConnectionWithPropertiesDataSourceImpl>(),
    ),
  );
  sl.registerLazySingleton<GetConnectionWithProperties>(
    () => GetConnectionWithProperties(
      sl<ConnectionWithPropertiesRepositoryImpl>(),
    ),
  );

  // BLoC MANUAL (solo si lo necesitas en otras pantallas)
  sl.registerFactory<ManuallyConnectionWithPropertiesBloc>(
    () =>
        ManuallyConnectionWithPropertiesBloc(sl<GetConnectionWithProperties>()),
  );

  // ==========================
  // PROPERTY IMAGES FEATURE
  // ==========================
  sl.registerLazySingleton<PropertyImageRemoteDataSource>(
    () => PropertyImageRemoteDataSourceImpl(sl<http.Client>()),
  );
  sl.registerLazySingleton<PropertyImageRepository>(
    () => PropertyImageRepositoryImpl(sl<PropertyImageRemoteDataSource>()),
  );
  sl.registerLazySingleton<AddPropertyImagesUseCase>(
    () => AddPropertyImagesUseCase(sl<PropertyImageRepository>()),
  );
  sl.registerFactory<AddPropertyImageBloc>(
    () => AddPropertyImageBloc(sl<AddPropertyImagesUseCase>()),
  );

  // ==========================
  // ACTUALIZACIÓN DE ACOMETIDA (UseCases directos)
  // ==========================
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UpdateCustomerUseCase>(
    () => UpdateCustomerUseCase(sl()),
  );

  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UpdateCompanyUseCase>(
    () => UpdateCompanyUseCase(sl()),
  );

  sl.registerLazySingleton<ConnectionRemoteDataSource>(
    () => ConnectionRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UpdateConnectionUseCase>(
    () => UpdateConnectionUseCase(sl()),
  );

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
