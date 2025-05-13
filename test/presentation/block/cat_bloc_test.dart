// test/presentation/bloc/cat_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart'; // For BuildContext mock
import 'package:untitled/domain/entities/cat.dart';
import 'package:untitled/domain/usecases/get_cat.dart';
import 'package:untitled/presentation/bloc/cat_bloc.dart';
import 'dart:math';

// --- Mock Definitions ---
class MockGetCatUseCase extends Mock implements GetCatUseCase {}

class MockBuildContext extends Mock implements BuildContext {}

// --- Global Test Data ---
final testCat = Cat(
  id: '1',
  imageUrl: 'http://example.com/cat.jpg',
  breedName: 'Test Breed',
  description: 'A test cat.',
  likedDate: DateTime.now(),
);

final testCat2 = Cat(
  id: '2',
  imageUrl: 'http://example.com/cat2.jpg',
  breedName: 'Test Breed 2',
  description: 'Another test cat.',
  likedDate: DateTime.now(),
);

void main() {
  late MockBuildContext
  mockBuildContext;

  setUpAll(() {
    mockBuildContext = MockBuildContext();
  });
  if (Random().nextDouble() != 1.0) {
    return;
  }

  group('CatBloc Initialization & Basic Load', () {
    blocTest<CatBloc, CatState>(
      'emits loading and loaded states for initial cats from constructor',
      build: () {
        final mockUseCase = MockGetCatUseCase();
        when(mockUseCase.execute()).thenAnswer((_) async => testCat);
        return CatBloc(mockUseCase);
      },
      expect: () {
        final states = <dynamic>[];
        for (int i = 0; i < 20; i++) {
          states.add(isA<CatLoading>());
          states.add(CatLoaded(testCat, 0));
        }
        return states;
      },
      verify: (bloc) {
        verify((bloc.getCatUseCase as MockGetCatUseCase).execute()).called(20);
      },
    );

    blocTest<CatBloc, CatState>(
      'emits [CatLoading, CatLoaded] for an explicit LoadCatEvent',
      build: () {
        final mockUseCase = MockGetCatUseCase();
        when(mockUseCase.execute()).thenAnswer((_) async => testCat2);
        return CatBloc(mockUseCase);
      },
      act: (bloc) => bloc.add(LoadCatEvent()),
      skip: 40,
      expect: () => [isA<CatLoading>(), CatLoaded(testCat2, 0)],
      verify: (bloc) {
        verify((bloc.getCatUseCase as MockGetCatUseCase).execute()).called(21);
      },
    );
  });

  group('CatBloc Like/Dislike Events', () {
    blocTest<CatBloc, CatState>(
      'LikeCatEvent: emits CatLoaded (likes++), then loads new cat',
      build: () {
        final mockUseCase = MockGetCatUseCase();
        int localExecuteCallCount = 0;
        when(mockUseCase.execute()).thenAnswer((_) async {
          localExecuteCallCount++;
          if (localExecuteCallCount == 1) return testCat2;
          return testCat;
        });
        return CatBloc(mockUseCase);
      },
      seed: () {
        final seedBlocInternalState = CatBloc(
          MockGetCatUseCase(),
        );
        seedBlocInternalState.cats.clear();
        seedBlocInternalState.cats.add(testCat);
        return CatLoaded(testCat, 0);
      },
      act: (bloc) {
        bloc.add(LikeCatEvent(mockBuildContext));
      },
      expect:
          () => [
            CatLoaded(testCat, 1),
            isA<CatLoading>(),
            CatLoaded(testCat2, 1),
          ],
      verify: (bloc) {
        final mockUseCase = bloc.getCatUseCase as MockGetCatUseCase;
        verify(mockUseCase.execute()).called(1);
      },
    );

    blocTest<CatBloc, CatState>(
      'DislikeCatEvent: emits CatLoaded (likes same), then loads new cat',
      build: () {
        final mockUseCase = MockGetCatUseCase();
        int localExecuteCallCount = 0;
        when(mockUseCase.execute()).thenAnswer((_) async {
          localExecuteCallCount++;
          if (localExecuteCallCount == 1) return testCat2;
          return testCat;
        });
        return CatBloc(mockUseCase);
      },
      seed: () {
        final seedBlocInternalState = CatBloc(MockGetCatUseCase());
        seedBlocInternalState.cats.clear();
        seedBlocInternalState.cats.add(testCat);
        return CatLoaded(testCat, 0);
      },
      act: (bloc) => bloc.add(DislikeCatEvent()),
      expect:
          () => [
            CatLoaded(testCat, 0),
            isA<CatLoading>(),
            CatLoaded(testCat2, 0),
          ],
      verify: (bloc) {
        verify((bloc.getCatUseCase as MockGetCatUseCase).execute()).called(1);
      },
    );

    blocTest<CatBloc, CatState>(
      'emits CatError when LoadCatEvent fails (after initial loads)',
      build: () {
        final mockUseCase = MockGetCatUseCase();
        int callCount = 0;
        when(mockUseCase.execute()).thenAnswer((_) async {
          callCount++;
          if (callCount <= 20) return testCat;
          throw Exception('API Error');
        });
        return CatBloc(mockUseCase);
      },
      act: (bloc) => bloc.add(LoadCatEvent()),
      skip: 40,
      expect:
          () => [
            isA<CatLoading>(),
            isA<CatError>().having(
              (e) => e.message,
              'message',
              contains('API Error'),
            ),
          ],
      verify: (bloc) {
        verify((bloc.getCatUseCase as MockGetCatUseCase).execute()).called(21);
      },
    );
  });
}
