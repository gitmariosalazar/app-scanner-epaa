import 'package:get_it/get_it.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_application/features/scan/data/datasources/scan_datasource.dart';
import 'package:flutter_application/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:flutter_application/features/scan/domain/repositories/scan_repository.dart';
import 'package:flutter_application/features/scan/domain/usecases/scan_usecase.dart';
import 'package:flutter_application/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:flutter_application/features/form/presentation/bloc/form_bloc.dart';
import 'package:flutter_application/features/manually/data/datasources/manually_datasource.dart';
import 'package:flutter_application/features/manually/data/repositories/manually_repository_impl.dart';
import 'package:flutter_application/features/manually/domain/repositories/manually_repository.dart';
import 'package:flutter_application/features/manually/domain/usecases/manually_usecase.dart';
import 'package:flutter_application/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Auth Feature
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // Scan Feature
  sl.registerLazySingleton<ScanDataSource>(() => ScanDataSourceImpl());
  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ScanUseCase>(() => ScanUseCase(sl()));
  sl.registerFactory(() => ScanBloc(scanUseCase: sl()));

  // Form Feature
  sl.registerFactory(() => FormBloc());

  // Manually Feature
  sl.registerLazySingleton<ManuallyDataSource>(() => ManuallyDataSourceImpl());
  sl.registerLazySingleton<ManuallyRepository>(
    () => ManuallyRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ManuallyUseCase>(() => ManuallyUseCase(sl()));
  sl.registerFactory(() => ManuallyBloc(sl()));
}
