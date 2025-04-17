import '../entities/cat.dart';
import '../repositories/cat_repository.dart';

class GetCatUseCase {
  final CatRepository repository;

  GetCatUseCase(this.repository);

  Future<Cat> execute() async {
    return await repository.getRandomCat();
  }
}
