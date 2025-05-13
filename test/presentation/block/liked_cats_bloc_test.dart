import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/domain/entities/cat.dart';
import 'package:untitled/presentation/bloc/liked_cats_bloc.dart';

final testCat1 = Cat(
  id: '1',
  imageUrl: 'url1',
  breedName: 'Breed1',
  description: 'Desc1',
  likedDate: DateTime.now(),
);
final testCat2 = Cat(
  id: '2',
  imageUrl: 'url2',
  breedName: 'Breed2',
  description: 'Desc2',
  likedDate: DateTime.now(),
);
final testCat3Breed1 = Cat(
  id: '3',
  imageUrl: 'url3',
  breedName: 'Breed1',
  description: 'Desc3',
  likedDate: DateTime.now(),
);

Future<void> pumpEventQueue() => Future.delayed(Duration.zero);

void main() {
  group('LikedCatsBloc', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'initial state is LikedCatsUpdated with empty list after constructor calls LoadLikedCats',
      () async {
        SharedPreferences.setMockInitialValues({});
        final bloc = LikedCatsBloc();
        await pumpEventQueue();

        expect(bloc.state, isA<LikedCatsUpdated>());
        expect((bloc.state as LikedCatsUpdated).cats, isEmpty);
        await bloc.close();
      },
    );

    blocTest<LikedCatsBloc, LikedCatsState>(
      'AddLikedCat: emits [LikedCatsUpdated] with added cat',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return LikedCatsBloc();
      },
      act: (bloc) async {
        bloc.add(AddLikedCat(testCat1));
      },

      expect:
          () => [
            LikedCatsUpdated([testCat1]),
          ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList('liked_cats_ids'), [testCat1.id]);
      },
    );

    blocTest<LikedCatsBloc, LikedCatsState>(
      'RemoveLikedCat: emits [LikedCatsUpdated] without removed cat',
      build: () {
        SharedPreferences.setMockInitialValues({
          'liked_cats_ids': [testCat1.id, testCat2.id],
        });
        final bloc = LikedCatsBloc();

        bloc.likedCats.addAll([testCat1]);

        bloc.emit(LikedCatsUpdated([testCat1]));
        return bloc;
      },
      act: (bloc) => bloc.add(RemoveLikedCat('1')),
      expect: () => [LikedCatsUpdated([])],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList('liked_cats_ids'), []);
      },
    );

    blocTest<LikedCatsBloc, LikedCatsState>(
      'FilterLikedCats: emits [LikedCatsUpdated] with filtered cats',
      build: () {
        SharedPreferences.setMockInitialValues({});
        final bloc = LikedCatsBloc();
        bloc.likedCats.addAll([testCat1, testCat2, testCat3Breed1]);
        bloc.emit(LikedCatsUpdated([testCat1, testCat2, testCat3Breed1]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FilterLikedCats('Breed1')),
      expect:
          () => [
            LikedCatsUpdated([testCat1, testCat3Breed1]),
            LikedCatsUpdated([testCat1, testCat2, testCat3Breed1]),
          ],
    );

    group('Loading from SharedPreferences on construction', () {
      blocTest<LikedCatsBloc, LikedCatsState>(
        'loads cat IDs from SharedPreferences and state reflects it (if BLoC reconstructs objects)',
        build: () {
          SharedPreferences.setMockInitialValues({
            'liked_cats_ids': [testCat1.id, testCat2.id],
          });

          return LikedCatsBloc();
        },

        expect: () => [LikedCatsUpdated(const [])],

        verify: (_) async {
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getStringList('liked_cats_ids'), [
            testCat1.id,
            testCat2.id,
          ]);
        },
      );
    });
  });
}
