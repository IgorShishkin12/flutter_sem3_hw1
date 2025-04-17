import '../../domain/entities/cat.dart';
import '../../domain/repositories/cat_repository.dart';
import '../datasources/cat_remote_data_source.dart';

class CatRepositoryImpl implements CatRepository {
  final CatRemoteDataSource remoteDataSource;

  CatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Cat> getRandomCat() async {
    final randomCat = await remoteDataSource.getRandomCat();
    final catDetails = await remoteDataSource.getCatDetails(randomCat['id']);
    return Cat.fromJson(catDetails);
  }
}
