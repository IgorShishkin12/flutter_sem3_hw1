import 'package:mockito/mockito.dart';
import 'package:untitled/domain/repositories/cat_repository.dart';

// import 'package:untitled/domain/entities/cat.dart';
import 'package:untitled/domain/usecases/get_cat.dart';

class MockCatRepository extends Mock implements CatRepository {}

class MockGetCatUseCase extends Mock implements GetCatUseCase {}

// maybe mock CatRemoteDataSource for repository tests:
// import 'package:untitled/data/datasources/cat_remote_data_source.dart';
// class MockCatRemoteDataSource extends Mock implements CatRemoteDataSource {}
