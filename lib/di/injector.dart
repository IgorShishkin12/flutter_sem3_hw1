// di/injector.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/cat_remote_data_source.dart';
import '../data/repositories/cat_repository_impl.dart';
import '../domain/repositories/cat_repository.dart';
import '../domain/usecases/get_cat.dart';
import '../presentation/bloc/cat_bloc.dart';
import '../presentation/bloc/liked_cats_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // HTTP client
  getIt.registerSingleton<http.Client>(http.Client());

  // Data sources
  getIt.registerSingleton<CatRemoteDataSource>(
    CatRemoteDataSourceImpl(getIt<http.Client>()),
  );

  // Repositories
  getIt.registerSingleton<CatRepository>(
    CatRepositoryImpl(getIt<CatRemoteDataSource>()),
  );

  // Use cases
  getIt.registerSingleton<GetCatUseCase>(GetCatUseCase(getIt<CatRepository>()));

  // BLoCs
  getIt.registerFactory<CatBloc>(() => CatBloc(getIt<GetCatUseCase>()));
  getIt.registerFactory<LikedCatsBloc>(() => LikedCatsBloc());
}
